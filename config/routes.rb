MawidaQA::Application.routes.draw do
  resources :tags, only: [ :index ] do
    resources :documents, only: [ :index ]
  end
  
  resources :documents do
    member do
      put :revise
      put :reject
      put :approve
      get :new_revision
    end
  end

  devise_for :users
  
  resources :users do
    member do
      get :edit_profile
      put :update_profile
    end
  end
  
  match 'private/:path', to: 'files#download', constraints: { path: /.+/ }
  
  root to: 'documents#index'
end
