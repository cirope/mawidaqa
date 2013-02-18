class AddKindToDocuments < ActiveRecord::Migration
  def change
    change_table :documents do |t|
      t.string :kind, default: 'document', null: false
    end
  end
end
