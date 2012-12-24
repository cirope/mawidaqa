module DynamicFormHelper
  def link_to_add_fields(name, form, association)
    new_object = form.object.send(association).klass.new
    id = new_object.object_id
    fields = form.fields_for(association, new_object, child_index: id) do |f|
      render(association.to_s.singularize, f: f)
    end

    link_to(
      name, '#', class: 'btn btn-small', title: name, data: {
        'id' => id,
        'dynamic-form-event' => 'addNestedItem',
        'dynamic-template' => fields.gsub("\n", ""),
        'show-tooltip' => true
      }
    )
  end
    
  def link_to_remove_nested_item(form)
    new_record = form.object.new_record?
    out = ''
    destroy = form.object.marked_for_destruction? ? 1 : 0
    
    out << form.hidden_field(:_destroy, class: 'destroy', value: destroy) unless new_record
    out << link_to(
      '&#x2718;'.html_safe, '#', title: t('label.delete'), class: 'iconic',
      data: {
        'dynamic-target' => ".#{form.object.class.name.underscore}",
        'dynamic-form-event' => (new_record ? 'removeItem' : 'hideItem'),
        'show-tooltip' => true
      }
    )

    raw out
  end
end
