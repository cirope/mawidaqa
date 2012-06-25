window.Document =
  resizeIFrame: ->
    height = $(window).height()
    
    height -= $('.navbar.navbar-fixed-top').outerHeight()
    height -= parseInt($('.navbar.navbar-fixed-top').css('margin-bottom'))
    height -= $('.nav.nav-tabs').outerHeight()
    height -= parseInt($('.content').css('padding-top'))
    
    $('iframe').height(height - 25)

jQuery ($)->
  if $('#c_documents').length > 0
    Document.resizeIFrame()
  
    $('#document_tag_list').tagit
      allowSpaces: true,
      removeConfirmation: true,
      tagSource: (search, showChoices)->
        $.getJSON '/tags', { q: search.term }, (data)->
          showChoices $.map(data, (t)-> t.name)
    
    $(window).on 'resize', Document.resizeIFrame