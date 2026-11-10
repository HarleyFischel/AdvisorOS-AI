require "rails_helper"

RSpec.describe "CRM CRUD workflows", type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { create(:user, organization: organization, role: :admin) }
  let!(:advisor) { create(:user, organization: organization, role: :advisor) }
  let!(:household) { create(:household, organization: organization, name: "Existing Household") }
  let!(:client) { create(:client, organization: organization, household: household, assigned_user: advisor) }

  before do
    post "/api/v1/session", params: { email: admin.email, password: "SafePass!2026" }, headers: csrf_headers
  end

  it "supports household create, update, and deletion" do
    expect {
      post "/api/v1/households", params: { name: "New Household", description: "Synthetic" }, headers: csrf_headers
    }.to change(Household, :count).by(1)
    expect(response).to have_http_status(:created)
    household_id = JSON.parse(response.body).dig("data", "id")

    patch "/api/v1/households/#{household_id}", params: { name: "Renamed Household" }, headers: csrf_headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data", "name")).to eq("Renamed Household")

    delete "/api/v1/households/#{household_id}", headers: csrf_headers
    expect(response).to have_http_status(:no_content)
    expect(Household.where(id: household_id)).to be_empty
  end

  it "protects households that still have clients from deletion" do
    delete "/api/v1/households/#{household.id}", headers: csrf_headers
    expect(response).to have_http_status(:unprocessable_content)
    expect(Household.exists?(household.id)).to be(true)
  end

  it "supports client create, update, and safe deletion" do
    post "/api/v1/clients", params: { first_name: "New", last_name: "Client", email: "new@example.test", household_id: household.id, assigned_user_id: advisor.id, estimated_aum: 1234.56 }, headers: csrf_headers
    expect(response).to have_http_status(:created)
    client_id = JSON.parse(response.body).dig("data", "id")

    patch "/api/v1/clients/#{client_id}", params: { status: "active", estimated_aum: 4567.89 }, headers: csrf_headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data", "status")).to eq("active")

    delete "/api/v1/clients/#{client_id}", headers: csrf_headers
    expect(response).to have_http_status(:no_content)
    expect(Client.exists?(client_id)).to be(false)
  end

  it "protects clients that still have activities or opportunities from deletion" do
    create(:activity, organization: organization, client: client, user: advisor)
    delete "/api/v1/clients/#{client.id}", headers: csrf_headers
    expect(response).to have_http_status(:unprocessable_content)
    expect(Client.exists?(client.id)).to be(true)
  end

  it "supports opportunity create, update, stage changes, and deletion" do
    post "/api/v1/opportunities", params: { client_id: client.id, owner_user_id: advisor.id, title: "New Opportunity", stage: "lead", estimated_value: 100_000, expected_close_date: Date.current + 30 }, headers: csrf_headers
    expect(response).to have_http_status(:created)
    opportunity_id = JSON.parse(response.body).dig("data", "id")

    patch "/api/v1/opportunities/#{opportunity_id}", params: { stage: "won", title: "Won Opportunity" }, headers: csrf_headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data", "stage")).to eq("won")

    delete "/api/v1/opportunities/#{opportunity_id}", headers: csrf_headers
    expect(response).to have_http_status(:no_content)
    expect(Opportunity.exists?(opportunity_id)).to be(false)
  end

  it "supports creating and listing client activities" do
    expect {
      post "/api/v1/clients/#{client.id}/activities", params: { activity_type: "call", summary: "Completed a synthetic review", occurred_at: Time.current }, headers: csrf_headers
    }.to change(Activity, :count).by(1)
    expect(response).to have_http_status(:created)

    get "/api/v1/clients/#{client.id}/activities"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Completed a synthetic review")
  end

  it "returns structured validation errors for malformed input" do
    post "/api/v1/clients", params: { first_name: "", last_name: "" }, headers: csrf_headers
    expect(response).to have_http_status(:unprocessable_content)
    body = JSON.parse(response.body)
    expect(body.dig("error", "message")).to eq("Validation failed")
    expect(body.dig("error", "details")).to include("first_name", "last_name")
  end
end
