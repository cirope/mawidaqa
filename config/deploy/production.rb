set :stage, :production
set :rails_env, 'production'

role :all, %w{mawidaqa.com}

server 'mawidaqa.com', user: 'deployer', roles: %w{web app db}
