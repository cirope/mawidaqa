module DocumentsHelper
  def document_status_options
    Document::STATUS.map { |s, v| [t("view.documents.status.#{s}"), v]}
  end
  
  def document_status_text(document)
    t("view.documents.status.#{Document::STATUS.invert[document.status]}")
  end
  
  def document_file_identifier(document)
    document.file.identifier || document.file_identifier if document.file?
  end
end
