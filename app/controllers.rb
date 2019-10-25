Serviziauto::App.controllers  do
  CAPTCHA_URL = 'https://www.ilportaledellautomobilista.it/web/portale-automobilista/verifica-copertura-rc?p_p_id=CoperturaRC_WAR_ServiziAlCittadinowar100SNAPSHOTesercizio&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_resource_id=captcha&p_p_cacheability=cacheLevelPage&p_p_col_id=_118_INSTANCE_hoIzOCy6I6vu__column-2&p_p_col_count=1&_CoperturaRC_WAR_ServiziAlCittadinowar100SNAPSHOTesercizio_veicolo=Veicolo&_CoperturaRC_WAR_ServiziAlCittadinowar100SNAPSHOTesercizio_action=sceltaTipologia'
  FORM_URL = 'https://www.ilportaledellautomobilista.it/web/portale-automobilista/verifica-copertura-rc?p_p_id=CoperturaRC_WAR_ServiziAlCittadinowar100SNAPSHOTesercizio&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&p_p_col_id=_118_INSTANCE_hoIzOCy6I6vu__column-2&p_p_col_count=1&_CoperturaRC_WAR_ServiziAlCittadinowar100SNAPSHOTesercizio_action=coperturaRC'

  set :protect_from_csrf, :except => ["/rca"]

  get :index, provides: :json do
    {
      message: "Padrino's gun is ready to shoot!",
      status: :ok
    }.to_json
  end

  get :captcha, provides: :json do
    agent = Mechanize.new
    captcha = Base64.encode64 agent.get(CAPTCHA_URL).content
    agent.cookie_jar.save_as("#{session[:session_id]}.yaml", session: true)

    {
      src: "data:image/jpeg;base64,#{captcha}",
      status: :ok
    }.to_json
  end

  post :rca, provides: :json, csrf_protection: false do
    status = :ok
    response = nil

    agent = Mechanize.new
    agent.cookie_jar.load("#{session[:session_id]}.yaml")
    page = agent.post(FORM_URL, {
      'tipoVeicolo' => params['tipoVeicolo'],
      'targa' => params['targa'],
      'captcha' => params['captcha'],
      'ricercaCoperturaVeicolo' => 'Ricerca'
    })
    message = page.search('#elenco-1 .errore-desc').text
    message = page.search('#elenco-1 .messaggio p').text if message.empty?

    if message.empty?
      k = page.search('table#listMovimenti thead tr th').map{ |th| th.text.downcase.gsub(/\W/, '_') }
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
