Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "top#main"

  get "top/main", to: "top#main"
  post "top/login", to: "top#login", as: :top_login
  get "top/logout", to: "top#logout", as: :top_logout

  resources :users, only: %i[new create]
  resource :profile, controller: :users, only: %i[show edit update]
  resources :tweets, only: :create
  resources :likes, only: %i[create destroy]
end
