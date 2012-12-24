class AddOrganizationToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :organization_id, :integer, null: false

    add_index :documents, :organization_id
  end
end
