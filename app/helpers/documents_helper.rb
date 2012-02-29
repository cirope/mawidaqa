module DocumentsHelper
  def document_status_text(document)
    t("view.documents.status.#{document.status}")
  end
  
  def document_file_identifier(document)
    document.file.identifier || document.file_identifier if document.file?
  end
end
