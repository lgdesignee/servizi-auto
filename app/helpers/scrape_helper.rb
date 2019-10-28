class ScrapeHelper
  URLS = {
    rca: {
      captcha: 'https://www.ilportaledellautomobilista.it/web/portale-automobilista/verifica-copertura-rc?p_p_id=CoperturaRC_WAR_ServiziAlCittadinowar100SNAPSHOTesercizio&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_resource_id=captcha&p_p_cacheability=cacheLevelPage&p_p_col_id=_118_INSTANCE_hoIzOCy6I6vu__column-2&p_p_col_count=1&_CoperturaRC_WAR_ServiziAlCittadinowar100SNAPSHOTesercizio_veicolo=Veicolo&_CoperturaRC_WAR_ServiziAlCittadinowar100SNAPSHOTesercizio_action=sceltaTipologia',
      form: 'https://www.ilportaledellautomobilista.it/web/portale-automobilista/verifica-copertura-rc?p_p_id=CoperturaRC_WAR_ServiziAlCittadinowar100SNAPSHOTesercizio&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&p_p_col_id=_118_INSTANCE_hoIzOCy6I6vu__column-2&p_p_col_count=1&_CoperturaRC_WAR_ServiziAlCittadinowar100SNAPSHOTesercizio_action=coperturaRC'
    },
    rev: {
      captcha: 'https://www.ilportaledellautomobilista.it/web/portale-automobilista/verifica-ultima-revisione?p_p_id=Revisione_WAR_ServiziAlCittadinowar100SNAPSHOTesercizio&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_resource_id=captcha&p_p_cacheability=cacheLevelPage&p_p_col_id=_118_INSTANCE_hoIzOCy6I6vu__column-2&p_p_col_count=1',
      form: 'https://www.ilportaledellautomobilista.it/web/portale-automobilista/verifica-ultima-revisione?p_p_id=Revisione_WAR_ServiziAlCittadinowar100SNAPSHOTesercizio&amp;p_p_lifecycle=0&amp;p_p_state=normal&amp;p_p_mode=view&amp;p_p_col_id=_118_INSTANCE_hoIzOCy6I6vu__column-2&amp;p_p_col_count=1&amp;_Revisione_WAR_ServiziAlCittadinowar100SNAPSHOTesercizio_action=revisione'
    }
  }
  def self.captcha(service, session)
    agent = Mechanize.new
    captcha = Base64.encode64 agent.get(URLS[service][:captcha]).content
    agent.cookie_jar.save_as("sessions/#{session[:session_id]}.yaml", session: true)

    {
      src: "data:image/jpeg;base64,#{captcha}",
      status: :ok
    }.to_json
  end

  def self.post(service, session, params)
    status = :ok
    response = nil

    agent = Mechanize.new
    agent.cookie_jar.load("sessions/#{session[:session_id]}.yaml")
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