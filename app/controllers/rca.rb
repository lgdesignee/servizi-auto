Serviziauto::App.controllers :rca do

  set :protect_from_csrf, :except => [/result/]

  get :captcha, provides: :json do
    ScrapeHelper.captcha(service: :rca, session: session)
  end

  post :result, provides: :json do
    ScrapeHelper.post(service: :rca, session: session, params: params)
  end

end
