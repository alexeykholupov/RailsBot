Rails.application.routes.draw do
  get 'synchronize/workpage'

  get 'home/index'

  resources :users

  root 'home#index'

  get '/users/:id', to: 'users#show'

  post '/work', to: 'synchronize#work'
end
