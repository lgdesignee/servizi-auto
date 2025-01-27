class RevHelper
  URLS = {
    captcha: 'https://www.ilportaledellautomobilista.it/interrogazionistoricorevisioni/noauth/captcha/generate',
    verify: 'https://www.ilportaledellautomobilista.it/interrogazionistoricorevisioni/noauth/captcha/verify',
    api: 'https://www.ilportaledellautomobilista.it/interrogazionistoricorevisioni/api/v1/storicorevisioni/A/GA985CW'
  }
  
  def self.captcha(service, session)
    agent = Mechanize.new
    response = JSON.parse(agent.post(URLS[:captcha]).body)

    {
      src: "data:image/jpeg;base64,#{response['image']}",
      token: response['id'],
      status: :ok
    }.to_json
  end

  def self.post(service, params)
    status = :ok
    response = nil

    agent = Mechanize.new
    agent.cookie_jar.load("sessions/#{params[:token]}.yaml")
    page = agent.post(URLS[service][:form], {
      'tipoVeicolo' => params['tipoVeicolo'],
      'targa' => params['targa'],
      'captcha' => params['captcha'],
      'ricercaCoperturaVeicolo' => 'Ricerca'
    })
    message = page.search('#elenco-1 .errore-desc').text
    message = page.search('#elenco-1 .messaggio p').text if message.empty?

    if message.empty?
      k = page.search('table#listMovimenti thead tr th').map{ |th| th.text }
      v = page.search('table#listMovimenti tbody tr td').map{ |th| th.text }
      response = Hash[k.zip(v)]
    else
      status = :ko
      response = { message: message.strip }
    end
    
    {
      response: response,
      status: status
    }.to_json
  end
end