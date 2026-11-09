require "rails_helper"

RSpec.describe "dashboard", type: :request do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, organization: organization) }

  before { post "/api/v1/session", params: { email: user.email, password: "SafePass!2026" }, headers: csrf_headers }

  it "aggregates persisted tenant data" do
    create_list(:client, 2, organization: organization, estimated_aum: 125_000)
    create(:household, organization: organization)
    get "/api/v1/dashboard"
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data", "metrics", "total_clients")).to eq(2)
    expect(JSON.parse(response.body).dig("data", "metrics", "total_estimated_aum")).to eq("250000.0")
  end
end
