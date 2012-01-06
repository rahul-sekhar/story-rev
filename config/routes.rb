StoryRev::Application.routes.draw do
  
  namespace :admin do
    get "logout" => "sessions#destroy", :as => "logout"
    get "login" => "sessions#new", :as => "login"
    post "login" => "sessions#create"
    
    root :to => "products#index"
    
    get "clear_images" => "cron#image_cron"
    
    resources :products do
      resources :editions do
        resources :copies
      end
    end
    resources :authors
    resources :illustrators
    resources :publishers
    resources :genres
    resources :keywords
    resources :product_tags
    resources :formats
    resources :cover_images
    
    resources :award_types do
      resources :awards
    end
  end
end