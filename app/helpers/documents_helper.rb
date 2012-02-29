module DocumentsHelper
  def document_status_text(document)
    t("view.documents.status.#{document.status}")
  end
  
  def document_file_identifier(document)
    document.file.identifier || document.file_identifier if document.file?
  end
  
  def document_actions(f)
    document = f.object
    main_action = f.button :submit, class: 'btn btn-primary'
    extra_actions = []
    actions = document.new_record? ? [] : [
      [:approve, approve_document_path(document)],
      [:revise, revise_document_path(document)],
      [:reject, reject_document_path(document)]
    ]
    
    actions.each do |action, path|
      if can?(action, document) && document.send("may_#{action}?")
        extra_actions << link_to(
          t("view.documents.actions.#{action}"), path, method: :put
        )
      end
    end
    
    if extra_actions.empty?
      main_action
    else
      render partial: 'shared/button_dropdown', locals: {
        main_action: main_action, extra_actions: extra_actions
      }
    end
  end
end
