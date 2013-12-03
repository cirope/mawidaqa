MawidaQA::Application.routes.draw do
  get '/launchpad', to: 'launchpad#index', as: 'launchpad'

  resources :organizations do
    resources :users
  end

  devise_for :users

  resources :users do
    member do
      get :edit_profile
      put :update_profile
    end
  end

  get 'private/:path', to: 'files#download', constraints: { path: /.+/ }

  get '/touch', to: 'touch#index', as: 'touch'
  get '/dashboard(.:format)', to: 'dashboard#index', as: 'dashboard'

  Job::TYPES.each do |job_type|
    get "/dashboard/#{job_type}(.:format)" => "dashboard##{job_type}",
      as: "#{job_type}_dashboard"
  end

  constraints OrganizationSubdomain do
    resources :documents do
      member do
        put :revise
        put :reject
        put :approve
        get :create_revision
      end
    end

    resources :tags, only: [ :index ] do
      resources :documents, only: [ :index ]
    end
  end

  root to: redirect('/users/sign_in')

  get 'errors/error_404'

  match '*not_found', to: 'errors#error_404', via: [:get, :put, :patch, :post, :delete]
end
