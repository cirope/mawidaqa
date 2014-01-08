set :stage, :production
set :rails_env, 'production'
set :branch, 'intranet'

role :all, %w{10.241.161.243}
# role :web, %w{10.1.74.146}
# role :app, %w{10.241.161.243}
# role :db,  %w{10.241.161.240}

server '10.241.161.243', user: 'deployer', roles: %w{web app db}
