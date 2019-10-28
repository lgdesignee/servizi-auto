$(function() {
  $('#service').on('change', loadCaptcha)

  $('#form').on('submit', function(e) {
    var form = $('#form').serializeArray()
    $.post('/' + getService() + '/result', form, function(r) {
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

  loadCaptcha()
})

function getService() {
  return $('#service').val()
}

function loadCaptcha() {
  $('#loading').show()
  $('#form').hide()
  $('#response').html('')

  $.get('/' + getService() + '/captcha', function(r) {
    $('#captcha').attr('src', r.src)
    $('#loading, #form').toggle()
  })
}