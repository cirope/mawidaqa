class AddRevisionUrlToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :revision_url, :text
  end
end
