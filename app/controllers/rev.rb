Serviziauto::App.controllers :rev do
  set :protect_from_csrf, :except => [/result/]
  
  get :captcha, provides: :json do
    RevHelper.captcha(:rev, session)
  end

  post :result, provides: :json, csrf_protection: false do
   RevHelper.post(:rev, params)
  end
end
