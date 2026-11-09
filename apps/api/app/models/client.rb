class Client < ApplicationRecord
  belongs_to :organization
  belongs_to :household, optional: true
  belongs_to :assigned_user, class_name: "User", optional: true
  has_many :opportunities, dependent: :restrict_with_error
  has_many :activities, dependent: :restrict_with_error

  enum :status, { prospect: "prospect", active: "active", inactive: "inactive" }
  validates :first_name, :last_name, presence: true, length: { maximum: 80 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :estimated_aum, numericality: { greater_than_or_equal_to: 0 }
  validate :associations_share_organization

  def full_name
    [first_name, last_name].join(" ")
  end

  private

  def associations_share_organization
    errors.add(:household, "belongs to another organization") if household && household.organization_id != organization_id
    errors.add(:assigned_user, "belongs to another organization") if assigned_user && assigned_user.organization_id != organization_id
  end
end
