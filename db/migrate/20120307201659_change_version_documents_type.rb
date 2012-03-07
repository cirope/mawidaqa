class ChangeVersionDocumentsType < ActiveRecord::Migration
  def change
    change_column :documents, :version, :string
  end
end
