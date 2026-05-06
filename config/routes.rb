Rails.application.routes.draw do
  devise_for :users
  root "events#index"

  resources :events, only: [ :index, :show, :new, :create ] do
    resource :registration, only: [ :create, :destroy ], controller: "event_registrations"
  end

  resources :users, only: [ :show ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
