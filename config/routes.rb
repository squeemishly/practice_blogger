Rails.application.routes.draw do
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  root 'articles#index'

  resources :users, only: [:new, :create]

  resources :articles do
    resources :comments, only: [:new, :create, :destroy]
  end
end
