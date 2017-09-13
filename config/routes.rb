Rails.application.routes.draw do
  get 'playlist_session/index'

  get 'auth/index'
  get 'auth/callback'
  get 'auth/logout'

  root 'auth#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
