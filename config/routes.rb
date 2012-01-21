MawidaQA::Application.routes.draw do
  resources :documents

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
