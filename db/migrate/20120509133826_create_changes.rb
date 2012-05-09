class CreateChanges < ActiveRecord::Migration
  def change
    create_table :changes do |t|
      t.text :content, null: false
      t.date :made_at, null: false
      t.integer :lock_version, null: false, default: 0
      t.references :document

      t.timestamps
    end
    
    add_index :changes, :document_id
  end
end
