Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  # Format: /api/<version (i.e: v1, v2)>/<controller (i.e: user)>/<route>
  #   Auth routes
  # /api/v1/user/login - user login
  # /api/v1/user/register - register new user
  # /api/v1/user/forgot_password - forgot password
  # /api/v1/user/update_password - update password
  # /api/v1/user/update - Update user profile
  # /api/v1/user/reset_password
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :users, only: :update do
        collection do
          post :login, to: 'sessions#create'
          post :register, to: 'registrations#create'
          post :reset_password, to: 'passwords#create'
          post :forgot_password, to: 'passwords#forgot_password'
        end
      end
    end
  end
end
