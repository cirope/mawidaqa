class CreateDocumentsTags < ActiveRecord::Migration
  def change
    create_table :documents_tags, id: false do |t|
      t.column :document_id, :integer, null: false
      t.column :tag_id, :integer, null: false
    end

    add_index :documents_tags, [:document_id, :tag_id], unique: true
  end
end
