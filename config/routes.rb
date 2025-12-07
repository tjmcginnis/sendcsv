Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resources :tables, only: [ :index, :show ], param: :public_id
  post "in/:table_id", to: "ingestions#create", as: "in"
  root "tables#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
