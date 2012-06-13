class RemoveFileFromDocuments < ActiveRecord::Migration
  def change
    remove_column :documents, :file
  end
end
