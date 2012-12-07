class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :identification
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end

    add_index :organizations, :name
    add_index :organizations, :identification, unique: true
  end
end
