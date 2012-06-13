class RemoveFileFromComments < ActiveRecord::Migration
  def change
    remove_column :comments, :file
  end
end
