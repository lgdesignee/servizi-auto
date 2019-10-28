Serviziauto::App.controllers :rev do
  set :protect_from_csrf, :except => [/result/]
  
  get :captcha, provides: :json do
    ScrapeHelper.captcha(service: :rev, session: session)
  end

  post :result, provides: :json, csrf_protection: false do
    ScrapeHelper.post(service: :rev, session: session, params: params)
  end

end
