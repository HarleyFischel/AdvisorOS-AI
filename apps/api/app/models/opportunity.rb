class Opportunity < ApplicationRecord
  belongs_to :organization
  belongs_to :client
  belongs_to :owner_user, class_name: "User"

  enum :stage, { lead: "lead", qualified: "qualified", proposal: "proposal", negotiation: "negotiation", won: "won", lost: "lost" }
  validates :title, presence: true, length: { maximum: 180 }
  validates :estimated_value, numericality: { greater_than_or_equal_to: 0 }
  validate :associations_share_organization

  private

  def associations_share_organization
    errors.add(:client, "belongs to another organization") if client && client.organization_id != organization_id
    errors.add(:owner_user, "belongs to another organization") if owner_user && owner_user.organization_id != organization_id
  end
end
