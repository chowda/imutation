Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "dashboard#index"

  get 'i', to: 'images#show', as: 'image_show'
  get 'i/help', to: 'images#help', as: 'image_help'

  resources :dashboard, only: [:index]
end
