Kenobi::Application.routes.draw do

  resources :users
  resources :users do
    resources :results
  end

  match '/home', :to => 'pages#home'
  match '/results', :to => 'pages#results'
  match '/about', :to => 'pages#about'
  match 'check_status', :to => 'users#check_status'
  match '/users/classify', :to => 'users#classify'
  match '/users/email', :to => 'users#email'

  root :to => 'pages#home'

end
