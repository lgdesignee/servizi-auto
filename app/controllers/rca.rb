Serviziauto::App.controllers :rca do
  enable :sessions
  set :protect_from_csrf, :except => [/result/]

  get :captcha, provides: :json do
    ScrapeHelper.captcha(:rca, session)
  end

  post :result, provides: :json do
    # ScrapeHelper.post(:rca, session, params)
    {
      session: session[:session_id]
    }.to_json
  end

end
