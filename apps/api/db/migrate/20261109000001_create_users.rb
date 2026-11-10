class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :full_name, null: false
      t.string :role, null: false, default: "viewer"
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_check_constraint :users, "role IN ('admin', 'advisor', 'viewer')", name: "users_role_valid"
  end
end
