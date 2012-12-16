class AddOrganizationToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :organization_id, :integer

    add_index :documents, :organization_id
  end
end
