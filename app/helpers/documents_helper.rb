module DocumentsHelper
  def document_status_text(document)
    t("view.documents.status.#{document.status}")
  end
  
  def document_file_identifier(document)
    document.file.identifier || document.file_identifier if document.file?
  end
  
  def document_actions(f)
    document = f.object
    action = document.new_record? ? 'create' : 'update'
    main_action_label = t(
      "helpers.submit.#{action}", model: Document.model_name.human
    )
    main_action = link_to(
      main_action_label, '#', class: 'btn btn-primary submit'
    )
    extra_actions = []
    actions = document.new_record? ? [] : [
      [:create_new_revision, true, new_revision_document_path(document), :get],
      [:approve, false, approve_document_path(document), :put],
      [:revise, false, revise_document_path(document), :put],
      [:reject, false, reject_document_path(document), :put]
    ]
    
    actions.each do |action, skip_may, path, method|
      if can?(action, document) && (skip_may || document.send("may_#{action}?"))
        extra_actions << link_to(
          t("view.documents.actions.#{action}"), path, method: method
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
