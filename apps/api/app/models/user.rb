class User < ApplicationRecord
  belongs_to :organization
  has_many :assigned_clients, class_name: "Client", foreign_key: :assigned_user_id, dependent: :restrict_with_error
  has_many :owned_opportunities, class_name: "Opportunity", foreign_key: :owner_user_id, dependent: :restrict_with_error
  has_many :activities, dependent: :restrict_with_error
  has_many :audit_events, foreign_key: :actor_user_id, dependent: :restrict_with_error

  has_secure_password
  enum :role, { admin: "admin", advisor: "advisor", viewer: "viewer" }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true, length: { maximum: 120 }
  normalizes :email, with: ->(email) { email.strip.downcase }
end
