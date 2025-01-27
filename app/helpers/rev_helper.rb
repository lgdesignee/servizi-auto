class RevHelper
  BASE_URL = 'https://www.ilportaledellautomobilista.it'
  URLS = {
    captcha: '/interrogazionistoricorevisioni/noauth/captcha/generate',
    verify: '/interrogazionistoricorevisioni/noauth/captcha/verify',
    api: '/interrogazionistoricorevisioni/api/v1/storicorevisioni'
  }
  
  def self.captcha(service, session)
    agent = Mechanize.new
    response = JSON.parse(agent.post(BASE_URL + URLS[:captcha]).body)

    {
      src: "data:image/jpeg;base64,#{response['image']}",
      token: response['id'],
      status: :ok
    }.to_json
  end

  def self.post(service, params)
    status = :ok
    conn = Faraday.new(BASE_URL)

    resp = conn.post(URLS[:verify]) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        id: params['token'],
        text: params['captcha']
      }.to_json
    end

    guid = JSON.parse(resp.body)['guid']
    
    if guid.nil?
      status = :ko
      response = { message: "Errore captcha non valido" }
    else
      resp = conn.get(BASE_URL + URLS[:api] + "/#{params['tipoVeicolo']}/#{params['targa']}") do |req|
        req.headers['guid'] = guid
      end

      info = JSON.parse(resp.body)['informations'].first
      response =  {
          'Data': info['datRvs'],
          'KM': info['numKmiPcsRvs'],
        }
    end
    
    { response:, status: }.to_json
  end
end