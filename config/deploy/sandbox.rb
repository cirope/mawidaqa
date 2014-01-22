set :stage, :sandbox
set :rails_env, 'production'

role :web, %w{deployer@localhost}
role :app, %w{deployer@localhost}
role :db,  %w{deployer@localhost}

server 'localhost', user: 'deployer', roles: %w{web app db}, ssh_options: { port: 2222 }
