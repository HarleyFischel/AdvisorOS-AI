class CreateActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :activities, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.references :client, null: false, type: :uuid, foreign_key: true
      t.references :user, null: false, type: :uuid, foreign_key: true
      t.string :activity_type, null: false, default: "note"
      t.text :summary, null: false
      t.datetime :occurred_at, null: false
      t.timestamps
    end
    add_index :activities, %i[organization_id occurred_at]
    add_check_constraint :activities, "activity_type IN ('note', 'call', 'email', 'meeting', 'task')", name: "activities_type_valid"
  end
end
