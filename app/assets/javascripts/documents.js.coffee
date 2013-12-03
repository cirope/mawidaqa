@Document =
  resizeIFrame: ->
    height = $(window).height()

    height -= $('.navbar.navbar-fixed-top').outerHeight()
    height -= parseInt($('.navbar.navbar-fixed-top').css('margin-bottom'))
    height -= $('.nav.nav-tabs').outerHeight()
    height -= parseInt($('.content').css('padding-top'))

    $('iframe').height(height - 25)

new Rule
  condition: -> $('#c_documents').length
  load: -> Document.resizeIFrame()

new Rule
  condition: -> $('#document_tag_list').length
  load: ->
    $('#document_tag_list').tagit
      allowSpaces: true,
      removeConfirmation: true,
      tagSource: (search, showChoices)->
        $.getJSON '/tags', { q: search.term }, (data)->
          showChoices $.map(data, (t)-> t.name)

    $(window).on 'resize', Document.resizeIFrame
  unload: ->
    $(window).off 'resize', Document.resizeIFrame
