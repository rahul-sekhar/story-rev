StoryRev::Application.routes.draw do
  
  root :to => "pages#store"
  
  resources :products
  
  get "order" => "orders#new"
  post "order" => "orders#create"
  delete "order" => "orders#destroy", :as => "destroy_order"
  
  get "shopping_cart" => "shopping_carts#index", :as => "shopping_cart"
  put "shopping_cart" => "shopping_carts#update"
  get "update_cart" => "shopping_carts#update", :as => "update_cart"
  
  get "about" => "pages#about"
  get "help" => "pages#help"
  
  post "subscribe" => "pages#subscribe"
  
  # Admin routes  
  namespace :admin do
    root :to => "products#search"
    
    get "logout" => "sessions#destroy", :as => "logout"
    get "login" => "sessions#new", :as => "login"
    post "login" => "sessions#create"
    
    get "priorities" => "pages#priorities", :as => "priorities"
    get "finances_config" => "pages#finances_config", :as => "finances_config"
    
    resources :products do
      resources :editions do
        resources :copies
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
      resources :order_copies
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
    resources :product_types
    resources :content_types
    resources :formats
    resources :countries
    resources :languages
    resources :collections do
      resources :products, :controller => "collection_products"
    end
    resources :award_types do
      resources :awards
    end
    resources :roles
    resources :transactions do
      collection do
        get 'summarised'
        get 'graph_data'
      end
    end
    resources :transaction_categories do
      get "toggle_record"
    end
    resources :payment_methods
    resources :accounts do
      get "to_cash"
      get "to_default"
    end
  end
end