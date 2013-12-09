module DocumentsHelper
  def document_status_text(document)
    t("view.documents.status.#{document.status}")
  end

  def show_document_kinds(form)
    if form.object.new_record?
      kinds = Document::KINDS.map { |k| [t("view.documents.kinds.#{k}"), k] }.sort

      form.input :kind, collection: kinds, prompt: true
    end
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
      [:create_revision, create_revision_document_path(document), :get],
      [:approve, approve_document_path(document), :patch],
      [:revise, revise_document_path(document), :patch],
      [:reject, reject_document_path(document), :patch]
    ]

    actions.each do |action, path, method|
      if can?(action, document) && document.send("may_#{action}?")
        options = {}
        options['method'] = method
        options['class'] = 'btn btn-primary' if extra_actions.empty?
        options['data-confirm'] = t('messages.confirmation') if method != :get

        extra_actions << link_to(
          t("view.documents.actions.#{action}"), path, options
        )
      end
    end

    if document.is_on_revision?
      extra_actions << link_to(
        t('view.documents.edit_current_revision'), document.current_revision
      )
    end

    if extra_actions.size == 1
      extra_actions.first
    else
      render 'shared/button_dropdown',
        main_action: extra_actions.shift,
        extra_actions: extra_actions,
        dropup: true
    end
  end

  def show_document_code_with_links(document)
    links = []

    unless document.on_revision?
      links << link_to_download_source_document(document)
      links << link_to_download_pdf(document)
    end

    links << link_to(
      document.code, document, title: t('label.show'),
      data: {'show-tooltip' => true}
    )

    if document.is_on_revision?
      links << link_to(
        content_tag(:span, nil, class: 'glyphicon glyphicon-eye-open'),
        document.current_revision,
        title: t('view.documents.show_revision'),
        data: {'show-tooltip' => true},
        class: 'icon'
      )
    end

    raw(links.join(' | '))
  end

  def link_to_related_document(document)
    link_to(
      t(
        'view.documents.related.html',
        code: document.code, status: document_status_text(document)
      ), document
    )
  end

  def document_edit_url(document)
    if document.on_revision?
      document_url = GdataExtension::Parser.edit_url(document.xml_reference)
      first_separator = document_url =~ /\?/ ? '&' : '?'

      "#{document_url}#{first_separator}embedded=true&hl=#{locale}"
    elsif document.revision_url.present?
      document_preview_url(document)
    end
  end

  def document_base_url(document)
    document.revision_url || GdataExtension::Base.new.last_revision_url(
      document.xml_reference, !document.spreadsheet?
    )
  end

  def document_preview_url(document)
    url = "#{document_base_url(document)}&exportFormat=pdf&format=pdf"

    "https://docs.google.com/viewer?embedded=true&hl=#{locale}&url=#{u url}"
  end

  def link_to_download_source_document(document, options = {})
    format = document.spreadsheet? ? 'xls' : 'doc'
    title = t('view.documents.download_source')
    label = options[:use_text] ?
      title :
      content_tag(:span, nil, class: 'glyphicon glyphicon-file')
    html_class = 'icon' unless options[:use_text]
    url = "#{document_base_url(document)}&exportFormat=#{format}&format=#{format}"

    link_to label, url, class: html_class, title: title,
      data: { 'show-tooltip' => true }
  end

  def link_to_download_pdf(document, options = {})
    title = t('view.documents.download_pdf')
    label = options[:use_text] ?
      title :
      content_tag(:span, nil, class: 'glyphicon glyphicon-download-alt')
    html_class = 'icon' unless options[:use_text]
    url = "#{document_base_url(document)}&exportFormat=pdf&format=pdf"

    link_to label, url, class: html_class, title: title,
      data: { 'show-tooltip' => true }
  end
end
