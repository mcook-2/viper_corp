Rails.application.routes.draw do
  get 'profiles/show'
  get 'profiles/edit'
  get 'profiles/update'
  get 'webhooks/stripe'
  devise_for :users

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
   root 'home#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Product routes
  resources :products, only: [:index, :show] do
    post 'add_to_cart', on: :member
  end

  # Stripe routes
  post 'checkout', to: 'checkouts#show'
  get 'checkout/success', to: 'checkouts#success'
  get 'billing', to: 'billing#show'

  # Cart routes
  get 'cart', to: 'cart#show'
  post 'cart/add_item'
  post 'cart/update_item'
  post 'cart/remove_item'
  get '/cart/update_item', to: 'cart#update_item'


  # Defines the root path route ("/")
  # root "posts#index"
end
