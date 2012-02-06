jQuery ($)->
  if $('#c_documents').length > 0
    $('#document_tag_list').tagit
      allowSpaces: true,
      removeConfirmation: true,
      tagSource: (search, showChoices)->
        $.getJSON '/tags', { q: search.term }, (data)->
          showChoices $.map(data, (t)-> t.name)
