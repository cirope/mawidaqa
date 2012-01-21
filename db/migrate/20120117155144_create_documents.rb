class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :status, null: false
      t.integer :version, null: false
      t.text :notes
      t.text :version_comments
      t.string :file
      t.boolean :current, null: false, default: false
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end
    
    add_index :documents, :name
    add_index :documents, :code
    add_index :documents, :status
    add_index :documents, :current
  end
end
