class Activity < ApplicationRecord
  belongs_to :organization
  belongs_to :client
  belongs_to :user

  enum :activity_type, { note: "note", call: "call", email: "email", meeting: "meeting", task: "task" }
  validates :summary, presence: true, length: { maximum: 2000 }
  validates :occurred_at, presence: true
  validate :associations_share_organization

  private

  def associations_share_organization
    errors.add(:client, "belongs to another organization") if client && client.organization_id != organization_id
    errors.add(:user, "belongs to another organization") if user && user.organization_id != organization_id
  end
end
