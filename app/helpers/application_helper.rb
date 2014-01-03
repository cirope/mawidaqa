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
