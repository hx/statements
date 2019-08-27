# List of colour literals
COLOURS = 'white red yellow green cyan blue magenta'.split ' '

# Populates the list of bank accounts in the sidebar
window.populate_accounts = (id) ->
  $el = $(id)
  for account in accounts
    a = $('<a role="button" class="btn btn-default active" />')
    a.text account.name
    a.append '<br/>'
    a.append $('<span class="small">').text(account.number)
    a.data id: account.id
    $el.append a

# AJAX layer
post = (page, data) -> $.ajax
  url: "q/#{page}"
  method: 'post'
  contentType: 'application/json; charset=UTF-8'
  dataType: page.match(/[^.]+$/)[0]
  data: JSON.stringify data

# Method to query the database
querying = false
query_again = false
query = ->

  # Handle interrupts
  if querying
    query_again = true
    return
  querying = true
  query_again = false

  # Clear content
  $('#content').html 'One moment...'

  # Submit data
  req = post 'search.html',
    order: $('#order').val()
    date_start: $('#date-start').val()
    date_end: $('#date-end').val()
    search: $('#text').val()
    type: $('#type .active').data 'type'
    accounts: $('#account-buttons .active').map(-> $(@).data 'id').toArray()
    colours: $('#colour .active').map(-> @className.match(/colour-(\w+)/)[1]).toArray()

  # On success
  req.done (result) -> $('#content').html result

  # On fail
  req.fail -> alert 'Query failed'

  # Clean up
  req.always ->
    querying = false
    query() if query_again

# Pad querying out a bit
query = _.debounce(query, 300)

# Method to change a transaction's colour
setColour = (transactionId, colour) -> post 'colour.json',
  id: transactionId
  colour: colour

setColours = (transactionIds, colour) ->
  [transactionId, rest...] = transactionIds
  op = setColour transactionId, colour
  op.fail -> alert 'Something went wrong. Try reloading?'
  op.done ->
    $tr = $("tr[data-id=#{transactionId}]")
    $tr[0].className = $tr[0].className.replace /colour-\w+/, "colour-#{colour}" if $tr[0]
    setColours rest, colour if rest[0]

$ ->
  # Set the date range to last financial year
  months = 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'.split ' '
  range = end: new Date
  range.end.setDate 1
  range.end.setMonth range.end.getMonth() - 1 until range.end.getMonth() is 6
  range.start = new Date(range.end)
  range.start.setFullYear range.start.getFullYear() - 1
  range.end.setDate range.end.getDate() - 1

  $("#date-#{k}").val "#{i.getDate()} #{months[i.getMonth()]} #{i.getFullYear()}" for k, i of range

  # Set up the date picker
  $('.input-daterange').datepicker
    format: "d M yyyy"
    startView: 2
    todayBtn: 'linked'
    autoclose: true
  .on 'changeDate', query

  # Order
  $('#order').on 'change', query

  # Dates
  $('date-range').on 'change', 'input', query

  # Search
  $('#text').on 'change keyup', query

  # Colours
  $('#colour').on 'click', 'a', query

  # Account buttons
  $accountButtons = $('#account-buttons a')
  $accountButtons.on 'click', query

  # Account select all/none buttons
  $('#account-button-bulk').on 'click', 'a', (e) ->
    set = $(e.currentTarget).data('set')
    $accountButtons.toggleClass 'active', set is 'on'
    query()

  # Radio button behaviour for transaction types
  $typeButtons = $('#type a')
  $('#type').on 'click', 'a', (e) ->
    return if $(e.currentTarget).hasClass 'active'
    $typeButtons.each -> $(this).toggleClass 'active', this is e.currentTarget
    query()

  # Handler for blurring colour pickers
  $picker = null
  $('body').on 'click', (e) ->
    target = e.currentTarget
    closePicker() unless $picker and (target is $picker[0] or $picker.find(target)[0])

  # Method to remove colour picker
  closePicker = ->
    $picker.remove() if $picker
    $picker = null

  # Handlers for clicks on colour pickers
  $('#content').on 'click', 'td.colour a.picker', (e) ->
    e.stopPropagation()
    closePicker()
    $tr = $(e.currentTarget).parents('tr').first()
    $td = $tr.find('td.colour')
    $picker = $('<ul class="colours">')
    $picker.append $('<li>').addClass("colour-#{i}").append('<a href="javascript:">') for i in COLOURS
    $picker.appendTo $td
    $picker.on 'click', 'a', (e) ->
      closePicker()
      $li = $(e.currentTarget).parents('li').first()
      colour = $li[0].className.match(/colour-(\w+)/)[1]
      if e.shiftKey
        setColours (x.dataset.id for x in $tr.parent().children()), colour
      else
        setColours [$tr.data('id')], colour

  # Do an initial query
  query()
