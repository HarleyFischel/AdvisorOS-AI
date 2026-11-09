require "rails_helper"

RSpec.describe "API security", type: :request do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, organization: organization, role: :advisor) }
  let!(:other_organization) { create(:organization) }
  let!(:other_client) { create(:client, organization: other_organization) }

  before do
    post "/api/v1/session", params: { email: user.email, password: "SafePass!2026" }, headers: csrf_headers
  end

  it "does not expose another organization's client" do
    get "/api/v1/clients/#{other_client.id}"
    expect(response).to have_http_status(:not_found)
    expect(response.body).not_to include(other_client.email)
  end

  it "rejects viewer writes" do
    viewer = create(:user, organization: organization, role: :viewer)
    delete "/api/v1/session", headers: csrf_headers
    post "/api/v1/session", params: { email: viewer.email, password: "SafePass!2026" }, headers: csrf_headers
    post "/api/v1/clients", params: { first_name: "No", last_name: "Write" }, headers: csrf_headers
    expect(response).to have_http_status(:forbidden)
  end

  it "rejects a client assigned to a cross-tenant household" do
    foreign_household = create(:household, organization: other_organization)
    post "/api/v1/clients", params: { first_name: "Cross", last_name: "Tenant", household_id: foreign_household.id }, headers: csrf_headers
    expect(response).to have_http_status(:unprocessable_entity)
  end
end
