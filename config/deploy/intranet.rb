set :stage, :production
set :rails_env, 'production'
set :branch, 'intranet'

role :all, %w{10.241.161.243}

server '10.241.161.243', user: 'deployer', roles: %w{web app db}
