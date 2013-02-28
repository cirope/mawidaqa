window.State =
  showMessages: [],
  sessionExpire: false

window.Helper =
  showMessage: (message, expired)->
    $('#time_left').find('.message').html(message)
    $('#time_left:not(:visible)').stop().fadeIn()

    State.sessionExpired = State.sessionExpired || expired
    
    $('iframe').remove() if State.sessionExpired

new Rule
  load: ->
    # For browsers with no autofocus support
    $('[autofocus]:not([readonly]):not([disabled]):visible:first').focus()
    $('[data-show-tooltip]').tooltip()

    timers = @map.timers = []
    
    $('.alert[data-close-after]').each (i, a)->
      timers.push setTimeout((-> $(a).alert('close')), $(a).data('close-after'))

  unload: -> clearTimeout timer for i, timer of @map.timers

jQuery ($) ->
  $(document).on 'click', 'a.submit', -> $(this).closest('form').submit(); false
  
  $(document).ajaxStart ->
    $('#loading_caption').stop(true, true).fadeIn(100)
  .ajaxStop ->
    $('#loading_caption').stop(true, true).fadeOut(100)
  
  $(document).on 'submit', 'form', ->
    $(this).find('input[type="submit"], input[name="utf8"]').attr 'disabled', true
    $(this).find('a.submit').removeClass('submit').addClass('disabled')
    $(this).find('.dropdown-toggle').addClass('disabled')

  if $.isArray(State.showMessages)
    $.each State.showMessages, ->
      _this = this
      this.timerId = window.setTimeout(
        (-> Helper.showMessage(_this.message, _this.expired)),
        this.time * 1000
      )
      
  $(document).bind
    # Restart timers
    ajaxStart: ->
      if !State.sessionExpired
        $('#time_left').fadeOut()
        
        $.each State.showMessages, ->
          window.clearTimeout this.timerId
          
          _this = this
          this.timerId = window.setTimeout(
            (-> Helper.showMessage(_this.message, _this.expired)),
            this.time * 1000
          )

  Inspector.instance().load()
