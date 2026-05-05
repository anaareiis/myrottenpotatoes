Rails.application.routes.draw do
  resources :movies do
    collection do
      post :search_tmdb
    end
  end
  root 'movies#index'
end
