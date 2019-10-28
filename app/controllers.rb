Serviziauto::App.controllers  do

  get :index, provides: :json do
    {
      message: "Padrino's gun is ready to shoot!",
      status: :ok
    }.to_json
  end

  get :demo do
    render 'demo/index'
  end

end
