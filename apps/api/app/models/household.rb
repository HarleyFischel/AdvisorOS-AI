class Household < ApplicationRecord
  belongs_to :organization
  has_many :clients, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 160 }
end
