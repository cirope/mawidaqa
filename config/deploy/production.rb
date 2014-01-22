set :stage, :production
set :rails_env, 'production'

role :web, %w{deployer@mawidaqa.com}
role :app, %w{deployer@mawidaqa.com}
role :db,  %w{deployer@mawidaqa.com}

server 'mawidaqa.com', user: 'deployer', roles: %w{web app db}
