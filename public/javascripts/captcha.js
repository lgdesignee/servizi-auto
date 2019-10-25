$(function() {
  $.get('/captcha', function(r) {
    $('#captcha').attr('src', r.src)
    $('#loading, #form').toggle()
  })

  $('#form').on('submit', function(e) {
    var form = $('#form').serializeArray()
    $.post('/rca', form, function(r) {
      $('#response').html(r.response)
    })
    e.preventDefault()
  })
})