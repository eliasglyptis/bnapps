Rails.application.routes.draw do
  devise_for :users
  root 'pages#home'
  get 'about', to: "pages#about"
  get 'dashboard', to: "pages#dashboard"
  get 'contact', to: "pages#contact"
  get 'thank_you', to: "pages#thank_you"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
