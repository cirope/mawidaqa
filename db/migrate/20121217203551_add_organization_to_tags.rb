class AddOrganizationToTags < ActiveRecord::Migration
  def change
    add_column :tags, :organization_id, :integer, null: false

    add_index :tags, :organization_id
  end
end
