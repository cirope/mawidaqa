class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :content, null: false
      t.string :file
      t.integer :lock_version, null: false, default: 0
      t.references :commentable, polymorphic: true

      t.timestamps
    end

    add_index :comments, [:commentable_type, :commentable_id]
  end
end
