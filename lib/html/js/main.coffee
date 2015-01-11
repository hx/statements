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

  # Collect data
  data =
    order: $('#order').val()
    date_start: $('#date-start').val()
    date_end: $('#date-end').val()
    search: $('#text').val()
    type: $('#type .active').data 'type'
    accounts: $('#account-buttons .active').map(-> $(@).data 'id').toArray()

  # Submit data
  req = $.ajax
    url: 'q/search.html'
    method: 'post'
    contentType: 'application/json; charset=UTF-8'
    dataType: 'html'
    data: JSON.stringify(data)

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

$ ->
  # Set the date range to today only
  months = 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'.split ' '
  now = new Date
  $('#date-range input').val "#{now.getDate()} #{months[now.getMonth()]} #{now.getFullYear()}"

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

  # Do an initial query
  query()
