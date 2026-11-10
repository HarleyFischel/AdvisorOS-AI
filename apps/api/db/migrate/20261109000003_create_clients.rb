class CreateClients < ActiveRecord::Migration[7.2]
  def change
    create_table :clients, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.references :household, type: :uuid, foreign_key: true
      t.references :assigned_user, type: :uuid, foreign_key: { to_table: :users }
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :phone
      t.string :status, null: false, default: "prospect"
      t.decimal :estimated_aum, null: false, precision: 15, scale: 2, default: 0
      t.timestamps
    end
    add_index :clients, %i[organization_id last_name first_name]
    add_index :clients, %i[organization_id status]
    add_check_constraint :clients, "status IN ('prospect', 'active', 'inactive')", name: "clients_status_valid"
    add_check_constraint :clients, "estimated_aum >= 0", name: "clients_aum_nonnegative"
  end
end
