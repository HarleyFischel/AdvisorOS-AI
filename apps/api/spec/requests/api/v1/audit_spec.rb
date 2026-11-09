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
end
