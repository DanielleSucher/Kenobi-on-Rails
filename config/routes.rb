Kenobi::Application.routes.draw do

  resources :users
  resources :users do
    resources :results
  end

  get "results/new"
  get "users/new"
  get "users/check_status"
  get "pages/home"
  get "pages/results"
  get "pages/about"
  post "users/classify"
  post "users/retrain"
  post "users/email"

  match '/home', :to => 'pages#home'
  match '/results', :to => 'pages#results'
  match '/about', :to => 'pages#about'
  match 'check_status', :to => 'users#check_status'

  match '/users/retrain', :to => 'users#retrain'
  match '/users/classify', :to => 'users#classify'
  match '/users/email', :to => 'users#email'

  root :to => 'pages#home'

end
