class LoginRateLimit < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :attempts, numericality: { greater_than_or_equal_to: 0 }
end
