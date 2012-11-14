StoryRev::Application.routes.draw do
  
  root :to => "pages#store"
  
  resources :books
  
  get "shopping_cart" => "orders#view_cart"
  put "shopping_cart" => "orders#update_cart"
  get "update_cart" => "orders#update_cart"

  get "order/step-:step" => "orders#show_step", step: /[1-4]/, as: "order_step"
  post "order/step-:step" => "orders#submit_step", step: /[1-3]/
  post "order/confirmation" => "orders#confirmation"
  get "order/cancel" => "orders#cancel_order"
  
  get "about" => "pages#about"
  get "help" => "pages#help"
  
  post "subscribe" => "pages#subscribe"

  # Story hour routes
  namespace :story_hour, path: "story-hour" do
    root :to => "pages#events"

    get "old" => "pages#old"
    get "about" => "pages#about"
  end
  
  # Admin routes  
  namespace :admin do
    root :to => "books#search"
    
    get "logout" => "sessions#destroy", :as => "logout"
    get "login" => "sessions#new", :as => "login"
    post "login" => "sessions#create"
    
    get "priorities" => "pages#priorities", :as => "priorities"
    get "finances_config" => "pages#finances_config", :as => "finances_config"
    
    resources :books do
      resources :editions do
        resources :copies
      end
      collection do
        get 'amazon_info'
        get 'search'
      end
    end
    
    post "stock_taking/add_copy" => "stock_taking#add_copy"
    delete "stock_taking/remove_copy" => "stock_taking#remove_copy"
    delete "stock_taking" => "stock_taking#clear", :as => "clear_stocks"
    
    resources :orders do
      resources :order_copies
      resources :extra_costs
      collection do
        get 'pending'
      end
    end
    resources :customers
    resources :copies
    resources :new_copies
    resources :cover_images
    resources :authors
    resources :illustrators
    resources :publishers
    resources :book_types
    resources :formats
    resources :countries
    resources :languages
    resources :collections do
      resources :books, :controller => "collection_books"
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
    resources :transaction_categories
    resources :payment_methods
    resources :accounts
    resources :default_cost_prices
    post "set_default_cost_price" => "default_cost_prices#set_default"
    resources :default_percentages
    post "set_default_percentage" => "default_percentages#set_default"
  end

  # 404 errors
  if Rails.application.config.show_error_pages
    match '*not_found', to: 'errors#error_404'
  end
end