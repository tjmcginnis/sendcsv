Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resources :tables, only: [ :index, :show ], param: :public_id
  root "tables#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
