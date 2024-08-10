Rails.application.routes.draw do
  authenticated :user, -> (user) { user.admin? } do
    get 'admin', to: 'admin#index'
    get 'admin/products', to: 'admin#products', as: 'admin_products'
    get 'admin/show_products/:id', to: 'admin#show_product', as: 'admin_product'
    get 'admin/orders'
    get 'admin/users'
    get 'admin/show_about_page'
    get 'users/profile'
  end
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  get '/u/:id', to:'users#profile', as: 'user'
   root 'home#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Product routes
  resources :products, only: [:index, :show] do
    post 'add_to_cart', on: :member
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
