class CreateHouseholds < ActiveRecord::Migration[7.2]
  def change
    create_table :households, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.timestamps
    end
    add_index :households, %i[organization_id name]
  end
end
