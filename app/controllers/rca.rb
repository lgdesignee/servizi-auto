Serviziauto::App.controllers :rca do

  set :protect_from_csrf, :except => [/result/]

  get :captcha, provides: :json do
    ScrapeHelper.captcha(:rca, session)
  end

  post :result, provides: :json do
    ScrapeHelper.post(:rca, session, params)
  end

end
