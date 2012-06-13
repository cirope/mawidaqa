class AddXmlReferenceToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :xml_reference, :text
  end
end
