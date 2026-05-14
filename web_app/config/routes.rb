Rails.application.routes.draw do
  root "wishlists#index"
  
  post "telegram/login", to: "telegram_auth#login"
  # Сохранение telegram_id в сессию
  post 'telegram/save_id', to: 'telegram#save_id', as: 'save_telegram_id'
  
  resources :wishlists do
    resources :gifts
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
