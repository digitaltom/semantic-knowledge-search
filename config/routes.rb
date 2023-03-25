Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "knowledge#index"
  post 'knowledge/ask', to: 'knowledge#ask'
  get 'knowledge/ask', to: 'knowledge#ask'

end
