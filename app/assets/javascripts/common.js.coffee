window.State = {
  showMessages: [],
  sessionExpire: false
}

window.Helper = {
  showMessage: (message, expired)->
    $('#time_left').find('h4').html(message)
    $('#time_left:not(:visible)').stop().fadeIn()

    State.sessionExpired = State.sessionExpired || expired
    
    $('iframe').remove() if State.sessionExpired
}

jQuery ($)->
  # For browsers with no autofocus support
  $('*[autofocus]:not([readonly]):not([disabled]):visible:first').focus()
  
  $('*[data-show-tooltip]').tooltip()
  
  $('a.submit').click -> $('form').submit(); return false
  
  $('#loading_caption').bind
    ajaxStart: `function() { $(this).stop(true, true).fadeIn(100) }`
    ajaxStop: `function() { $(this).stop(true, true).fadeOut(100) }`
  
  $('form').submit ->
    $(this).find('input[type="submit"], input[name="utf8"]')
    .attr 'disabled', true
    $(this).find('a.submit').removeClass('submit').addClass('disabled')
    $(this).find('.dropdown-toggle').addClass('disabled')

  if $('.alert[data-close-after]').length > 0
    $('.alert[data-close-after]').each (i, a)->
      setTimeout(
        (-> $(a).find('a.close').trigger('click')), $(a).data('close-after')
      )
  
  if $.isArray(State.showMessages)
    $.each State.showMessages, ->
      this.timerId = window.setTimeout(
        "Helper.showMessage('#{this.message}', #{this.expired})",
        this.time * 1000
      )
      
  $(document).bind
    # Restart timers
    ajaxStart: ->
      if !State.sessionExpired
        $('#time_left').fadeOut()
        
        $.each State.showMessages, ->  
          window.clearTimeout this.timerId

          this.timerId = window.setTimeout(
            "Helper.showMessage('#{this.message}', #{this.expired})",
            this.time * 1000
          )
