Rails.application.routes.draw do
  
  root "wishlists#index"
  
  
  post "/set_telegram_session", to: "telegram_session#create"

  resources :wishlists do
    resources :gifts
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
