class AuditEvent < ApplicationRecord
  belongs_to :organization
  belongs_to :actor_user, class_name: "User"

  validates :action, :record_type, :record_id, presence: true
  validate :metadata_is_object

  private

  def metadata_is_object
    errors.add(:metadata, "must be an object") unless metadata.is_a?(Hash)
  end
end
