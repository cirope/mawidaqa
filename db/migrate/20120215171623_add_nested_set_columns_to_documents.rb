class AddNestedSetColumnsToDocuments < ActiveRecord::Migration
  def change
    change_table :documents do |t|
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth # this is optional.
    end

    add_index :documents, :parent_id
  end
end
