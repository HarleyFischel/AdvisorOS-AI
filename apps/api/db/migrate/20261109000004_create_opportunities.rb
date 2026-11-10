class CreateOpportunities < ActiveRecord::Migration[7.2]
  def change
    create_table :opportunities, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.references :client, null: false, type: :uuid, foreign_key: true
      t.references :owner_user, null: false, type: :uuid, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.string :stage, null: false, default: "lead"
      t.decimal :estimated_value, null: false, precision: 15, scale: 2, default: 0
      t.date :expected_close_date
      t.timestamps
    end
    add_index :opportunities, %i[organization_id stage]
    add_check_constraint :opportunities, "stage IN ('lead', 'qualified', 'proposal', 'negotiation', 'won', 'lost')", name: "opportunities_stage_valid"
    add_check_constraint :opportunities, "estimated_value >= 0", name: "opportunities_value_nonnegative"
  end
end
