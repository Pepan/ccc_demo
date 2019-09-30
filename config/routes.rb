Rails.application.routes.draw do
  resources :sessions, only: %i[new create destroy]
  resources :users

  get 'users/:id/confirm/:token', to: 'users#confirm', as: 'confirm_user'
  get 'page/something'

  root 'page#home'
end
