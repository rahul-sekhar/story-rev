StoryRev::Application.routes.draw do
  
  root :to => "pages#store", :as => "store"
  
  resources :products
  
  get "order" => "orders#new"
  post "order" => "orders#create"
  delete "order" => "orders#destroy", :as => "destroy_order"
  
  get "more_info" => "pages#more_info"
  get "shopping_cart" => "shopping_carts#index", :as => "shopping_cart"
  put "shopping_cart" => "shopping_carts#update"
  get "update_cart" => "shopping_carts#update", :as => "update_cart"
  
  # Admin routes  
  namespace :admin do
    root :to => "products#search"
    
    get "logout" => "sessions#destroy", :as => "logout"
    get "login" => "sessions#new", :as => "login"
    post "login" => "sessions#create"
    get "clear_images" => "cron#image_cron"
    
    resources :products do
      resources :editions do
        resources :copies
        resources :new_copies
      end
      collection do
        get 'amazon_info'
        get 'search'
      end
    end
    
    post "stocks/add_copy" => "stocks#add_copy"
    delete "stocks/remove_copy" => "stocks#remove_copy"
    delete "stocks" => "stocks#clear", :as => "clear_stocks"
    
    resources :orders do
      collection do
        get 'pending'
      end
    end
    resources :copies
    resources :new_copies
    resources :cover_images
    resources :authors
    resources :illustrators
    resources :publishers
    resources :keywords
    resources :product_types
    resources :content_types
    resources :formats
    resources :countries
    resources :languages
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