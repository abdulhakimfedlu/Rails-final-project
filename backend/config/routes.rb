Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes - matching Node.js structure exactly (no versioning)
  namespace :api do
    # Categories routes - POST /, GET /, PUT /:id, DELETE /:id
    resources :categories, only: [:index, :create, :update, :destroy]
    
    # Comments routes - POST /, GET /
    resources :comments, only: [:index, :create]
    
    # Employees routes - POST /, GET /, GET /:id, PUT /:id, DELETE /:id
    resources :employees, only: [:index, :show, :create, :update, :destroy]
    
    # Menus routes - GET /category/:categoryId, POST /category/:categoryId, PUT /:id, DELETE /:id
    resources :menus, only: [:update, :destroy] do
      collection do
        get 'category/:category_id', to: 'menus#by_category'
        post 'category/:category_id', to: 'menus#create_under_category'
      end
    end
    
    # Ratings routes - POST /, GET /menu/:menuId, GET /menu/:menuId/average
    resources :ratings, only: [:create] do
      collection do
        get 'menu/:menu_id', to: 'ratings#by_menu'
        get 'menu/:menu_id/average', to: 'ratings#average'
      end
    end
    
    # Users routes - POST /register, POST /login, GET /current, POST /change-password, POST /change-phone
    post 'users/register', to: 'users#register'
    post 'users/login', to: 'users#login'
    get 'users/current', to: 'users#current_user'
    post 'users/change-password', to: 'users#change_password'
    post 'users/change-phone', to: 'users#update_phone_number'
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
