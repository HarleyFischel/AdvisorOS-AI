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
    expect(response).to have_http_status(:unprocessable_content)
    expect(Client.where(first_name: "Cross")).to be_empty
  end

  it "rejects a client assigned to a cross-tenant user" do
    foreign_user = create(:user, organization: other_organization)
    post "/api/v1/clients", params: { first_name: "Cross", last_name: "Advisor", assigned_user_id: foreign_user.id }, headers: csrf_headers
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "ignores organization mass assignment and uses the authenticated tenant" do
    post "/api/v1/clients", params: { organization_id: other_organization.id, first_name: "Safe", last_name: "Tenant" }, headers: csrf_headers
    expect(response).to have_http_status(:created)
    expect(Client.find(JSON.parse(response.body).dig("data", "id")).organization).to eq(organization)
  end

  it "rejects cross-tenant opportunity associations" do
    foreign_client = create(:client, organization: other_organization)
    foreign_user = create(:user, organization: other_organization)
    post "/api/v1/opportunities", params: { client_id: foreign_client.id, owner_user_id: foreign_user.id, title: "Cross tenant", stage: "lead", estimated_value: 100 }, headers: csrf_headers
    expect(response).to have_http_status(:unprocessable_content)
    expect(Opportunity.where(title: "Cross tenant")).to be_empty
  end

  it "rejects cross-tenant activity paths without leaking records" do
    foreign_client = create(:client, organization: other_organization)
    get "/api/v1/clients/#{foreign_client.id}/activities"
    expect(response).to have_http_status(:not_found)
    post "/api/v1/clients/#{foreign_client.id}/activities", params: { activity_type: "note", summary: "No access", occurred_at: Time.current }, headers: csrf_headers
    expect(response).to have_http_status(:not_found)
    expect(response.body).not_to include("No access")
  end

  it "rejects state-changing requests without a valid CSRF token" do
    post "/api/v1/households", params: { name: "Missing token" }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Request could not be verified")
  end

  it "allows viewers to read but not mutate CRM records" do
    viewer = create(:user, organization: organization, role: :viewer)
    delete "/api/v1/session", headers: csrf_headers
    post "/api/v1/session", params: { email: viewer.email, password: "SafePass!2026" }, headers: csrf_headers
    get "/api/v1/households"
    expect(response).to have_http_status(:ok)
    post "/api/v1/households", params: { name: "No write" }, headers: csrf_headers
    expect(response).to have_http_status(:forbidden)
    post "/api/v1/opportunities", params: { title: "No write" }, headers: csrf_headers
    expect(response).to have_http_status(:forbidden)
    post "/api/v1/clients/#{create(:client, organization: organization).id}/activities", params: { activity_type: "note", summary: "No write", occurred_at: Time.current }, headers: csrf_headers
    expect(response).to have_http_status(:forbidden)
  end

  it "logs out the current session" do
    delete "/api/v1/session", headers: csrf_headers
    get "/api/v1/me"
    expect(response).to have_http_status(:unauthorized)
  end
end
