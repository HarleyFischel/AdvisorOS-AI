class CreateAuditEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :audit_events, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.references :actor_user, null: false, type: :uuid, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :record_type, null: false
      t.uuid :record_id, null: false
      t.jsonb :metadata, null: false, default: {}
      t.datetime :created_at, null: false
    end
    add_index :audit_events, %i[organization_id created_at]
    add_index :audit_events, %i[record_type record_id]
  end
end
