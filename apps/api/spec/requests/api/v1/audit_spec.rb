require "rails_helper"

RSpec.describe "audit events", type: :request do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, organization: organization, role: :admin) }
  before { post "/api/v1/session", params: { email: user.email, password: "SafePass!2026" }, headers: csrf_headers }

  it "records safe mutation metadata" do
    expect { post "/api/v1/households", params: { name: "New synthetic household" }, headers: csrf_headers }.to change(AuditEvent, :count).by(1)
    event = AuditEvent.order(:created_at).last
    expect(event.action).to eq("household.created")
    expect(event.actor_user).to eq(user)
    expect(event.metadata.keys).not_to include("password", "session")
  end

  it "records client, opportunity, activity, update, and delete mutations" do
    client = create(:client, organization: organization)
    opportunity = create(:opportunity, organization: organization, client: client, owner_user: user)
    expect { patch "/api/v1/clients/#{client.id}", params: { first_name: "Updated" }, headers: csrf_headers }.to change(AuditEvent, :count).by(1)
    expect(AuditEvent.order(:created_at).last.action).to eq("client.updated")

    expect { post "/api/v1/clients/#{client.id}/activities", params: { activity_type: "note", summary: "Safe audit activity", occurred_at: Time.current }, headers: csrf_headers }.to change(AuditEvent, :count).by(1)
    expect(AuditEvent.order(:created_at).last.action).to eq("activity.created")

    expect { patch "/api/v1/opportunities/#{opportunity.id}", params: { stage: "won" }, headers: csrf_headers }.to change(AuditEvent, :count).by(1)
    expect(AuditEvent.order(:created_at).last.action).to eq("opportunity.updated")
  end

  it "does not allow ordinary input to set audit ownership or metadata" do
    foreign = create(:user, organization: organization)
    post "/api/v1/households", params: { name: "Safe input", actor_user_id: foreign.id, metadata: { password: "do-not-store" } }, headers: csrf_headers
    event = AuditEvent.order(:created_at).last
    expect(event.actor_user).to eq(user)
    expect(event.metadata).to eq("summary" => "CRM record mutation")
  end
end
