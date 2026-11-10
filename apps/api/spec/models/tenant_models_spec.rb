require "rails_helper"

RSpec.describe "tenant-aware domain models" do
  it "validates a client cannot associate with another organization's household" do
    first = create(:organization); second = create(:organization)
    client = build(:client, organization: first, household: create(:household, organization: second))
    expect(client).not_to be_valid
    expect(client.errors[:household]).to include("belongs to another organization")
  end

  it "requires non-negative AUM and a valid role" do
    expect(build(:client, estimated_aum: -1)).not_to be_valid
    expect { build(:user, role: "operator") }.to raise_error(ArgumentError)
  end

  it "requires opportunity associations to share an organization" do
    first = create(:organization); second = create(:organization)
    opportunity = Opportunity.new(organization: first, client: create(:client, organization: second), owner_user: create(:user, organization: first), title: "Cross-tenant", stage: :qualified, estimated_value: 100)
    expect(opportunity).not_to be_valid
  end
end
