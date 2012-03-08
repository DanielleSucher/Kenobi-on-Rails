Kenobi::Application.routes.draw do

  resources :users
  resources :users do
    resources :words
    resources :results
  end

  get "words/new"
  get "results/new"
  get "users/new"
  get "pages/home"
  get "pages/results"
  get "pages/about"
  post "users/classify"
  post "users/retrain"

  match '/home', :to => 'pages#home'
  match '/results', :to => 'pages#results'
  match '/about', :to => 'pages#about'

  match '/users/retrain', :to => 'users#retrain'
  match '/users/classify', :to => 'users#classify'

  root :to => 'pages#home'

end
