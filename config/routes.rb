StoryRev::Application.routes.draw do
  
  root :to => "pages#store"
  resources :products
  
  # Admin routes  
  namespace :admin do
    root :to => "products#index"
    
    get "logout" => "sessions#destroy", :as => "logout"
    get "login" => "sessions#new", :as => "login"
    post "login" => "sessions#create"
    get "clear_images" => "cron#image_cron"
    
    resources :products do
      resources :editions do
        resources :copies
      end
      collection do
        get 'amazon_info'
      end
    end
    resources :cover_images
    resources :authors
    resources :illustrators
    resources :publishers
    resources :keywords
    resources :product_tags
    resources :formats
    resources :themes do
      resources :products, :controller => "theme_products"
      put :update_products
    end
    resources :theme_icons
    resources :award_types do
      resources :awards
    end
    resources :roles
  end
end