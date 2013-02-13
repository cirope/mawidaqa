new Rule
  condition: -> $('input[data-date-picker]').length
  load: ->
    @map.focus_function = ->
      $(this).datepicker
        showOn: 'both',
        onSelect: -> $(this).datepicker('hide')
      .removeAttr('data-date-picker').focus()

    $(document).on 'focus keydown click', 'input[data-date-picker]', @map.focus_function
  unload: ->
    $(document).off 'focus keydown click', 'input[data-date-picker]', @map.focus_function
