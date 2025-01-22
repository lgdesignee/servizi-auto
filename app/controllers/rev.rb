Serviziauto::App.controllers :rev do
  set :protect_from_csrf, :except => [/result/]
  
  get :captcha, provides: :json do
    ScrapeHelper.captcha(:rev, session)
  end

  post :result, provides: :json, csrf_protection: false do
    ScrapeHelper.post(:rev, params)
  end
end
