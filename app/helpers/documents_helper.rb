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
    
    document_context_actions(document, main_action)
  end
  
  def document_context_actions(document, main_action)
    extra_actions = [main_action].compact
    actions = document.new_record? ? [] : [
      [:create_new_revision, new_revision_document_path(document), :get],
      [:approve, approve_document_path(document), :put],
      [:revise, revise_document_path(document), :put],
      [:reject, reject_document_path(document), :put]
    ]
    
    actions.each do |action, path, method|
      if can?(action, document) && document.send("may_#{action}?")
        extra_actions << link_to(
          t("view.documents.actions.#{action}"), path,
          method: method, class: ('btn btn-primary' if extra_actions.empty?)
        )
      end
    end
    
    if document.is_on_revision?
      extra_actions << link_to(
        t('view.documents.edit_current_revision'),
        document.children.on_revision.first
      )
    end
      
    if extra_actions.size == 1
      extra_actions.first
    else
      render partial: 'shared/button_dropdown', locals: {
        main_action: extra_actions.shift, extra_actions: extra_actions
      }
    end
  end
  
  def show_document_code_with_links(document)
    links = []
    
    links << link_to(
      document.code, document, title: t('label.show'),
      data: {'show-tooltip' => true}
    )
    
    links << link_to_download(document.file_url)
    
    if document.is_on_revision?
      links << link_to(
        '&#xe025;'.html_safe, document.children.on_revision.first,
        class: 'iconic', title: t('view.documents.show_revision'),
        data: {'show-tooltip' => true}
      )
    end
    
    raw(links.join(' | '))
  end
end
