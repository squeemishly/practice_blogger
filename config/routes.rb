Rails.application.routes.draw do
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  root 'articles#index'

  resources :users, only: [:new, :create, :edit, :update, :show]

  resources :articles do
    resources :comments, only: [:new, :create, :destroy, :edit, :update]
  end

  namespace :admin do
    resources :dashboard, only: [:show]
  end

  resources :search, only: [:show]
  resources :suspensions, only: [:create, :update, :index]
  resources :admins, only: [:new, :destroy]
end
