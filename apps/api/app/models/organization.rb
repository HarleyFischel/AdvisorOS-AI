class Organization < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :households, dependent: :restrict_with_error
  has_many :clients, dependent: :restrict_with_error
  has_many :opportunities, dependent: :restrict_with_error
  has_many :activities, dependent: :restrict_with_error
  has_many :audit_events, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 120 }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }
end
