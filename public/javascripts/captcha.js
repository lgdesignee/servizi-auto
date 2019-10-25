$(function() {
  $.get('/captcha', function(r) {
    $('#captcha').attr('src', r.src)
    $('#loading, #form').toggle()
  })

  $('#form').on('submit', function(e) {
    var form = $('#form').serializeArray()
    $.post('/rca', form, function(r) {
      if ( r.status == 'ok' ) {
        html = '<table>'
        $.each(r.response, function(k, v) {
          html += '<tr><td>' + k + '</td><td>' + v + '</td></tr>'
        })
        html += '</table>'

        $('#response').html(html)
      } else {
        $('#response').html(r.response.message)
      }
    })
    e.preventDefault()
  })
})