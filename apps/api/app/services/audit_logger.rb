class AuditLogger
  def self.call(actor:, action:, record:, metadata: {})
    AuditEvent.create!(
      organization: actor.organization,
      actor_user: actor,
      action: action,
      record_type: record.class.name,
      record_id: record.id,
      metadata: metadata.slice(:changed).merge("summary" => "CRM record mutation")
    )
  end
end
