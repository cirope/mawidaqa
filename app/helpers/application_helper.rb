module ApplicationHelper
  def title
    [t('app_name'), @title].compact.join(' | ')
  end

  def markdown(text)
    MARKDOWN_RENDERER.render(text).html_safe
  end

  def show_menu_link(options = {})
    name = t("menu.#{options[:name]}")
    classes = []

    classes << 'active' if [*options[:controllers]].include?(controller_name)

    content_tag(
      :li, link_to(name, options[:path]),
      class: (classes.empty? ? nil : classes.join(' '))
    )
  end

  def show_button_dropdown(main_action, extra_actions = [], options = {})
    if extra_actions.blank?
      main_action
    else
      out = ''.html_safe

      out << render(
        'shared/button_dropdown',
        main_action: main_action, extra_actions: extra_actions, dropup: false
      )
    end
  end

  def pagination_links(objects, params = nil)
    pagination_links = will_paginate objects,
      inner_window: 1, outer_window: 1, params: params,
      renderer: BootstrapPaginationHelper::LinkRenderer,
      class: 'pagination pagination-sm pull-right'
    page_entries = content_tag(
      :blockquote,
      content_tag(
        :small,
        page_entries_info(objects),
        class: 'page-entries pull-right'
      ),
      class: 'hidden-lg'
    )

    pagination_links ||= empty_pagination_links

    pagination_links + page_entries
  end

  def empty_pagination_links
    previous_tag = content_tag(
      :li,
      content_tag(:a, t('will_paginate.previous_label').html_safe),
      class: 'previous disabled'
    )
    next_tag = content_tag(
      :li,
      content_tag(:a, t('will_paginate.next_label').html_safe),
      class: 'next disabled'
    )

    content_tag(:ul, previous_tag + next_tag, class: 'pager pull-right')
  end

  def document_tag_list
    @_document_tag_list ||= current_organization.tags.order('name ASC')
  end

  def copy_attribute_errors(from, to, form_builder)
    form_builder.object.errors[from].each do |message|
      form_builder.object.errors.add(to, message)
    end
  end

  Job::TYPES.each do |type|
    define_method("current_user_is_#{type}?") do
      current_organization && current_user.jobs.in_organization(current_organization).any?(&:"#{type}?")
    end
  end
end
