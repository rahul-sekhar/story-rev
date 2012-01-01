StoryRev::Application.routes.draw do
  
  namespace :admin do
    get "logout" => "sessions#destroy", :as => "logout"
    get "login" => "sessions#new", :as => "login"
    post "login" => "sessions#create"
    
    root :to => "products#index"
    
    resources :products
    
    resources :award_types do
      resources :awards
    end
  end
end