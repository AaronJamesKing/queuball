Rails.application.routes.draw do

  get 'auth/index'
  get 'auth/callback'
  get 'auth/logout'

  resources :playlists do
    resources :members, only: [:new, :create, :update, :delete]
  end

  root 'auth#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
