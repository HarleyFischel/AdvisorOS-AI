class EnableExtensionsAndCreateOrganizations < ActiveRecord::Migration[7.2]
  def change
    enable_extension "pgcrypto"
    create_table :organizations, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.timestamps
    end
    add_index :organizations, :slug, unique: true
  end
end
