require 'bundler/capistrano'

set :application, 'mawidaqa'
set :repository,  'https://github.com/francocatena/mawidaqa.git'
set :deploy_to, '/var/rails/mawidaqa'
set :user, 'deployer'
set :group_writable, false
set :shared_children, %w(system log pids private public config)
set :use_sudo, false

set :scm, :git
set :branch, 'master'

role :web, 'mawidaqa.com'
role :app, 'mawidaqa.com'
role :db, 'mawidaqa.com', primary: true

before 'deploy:finalize_update', 'deploy:create_shared_symlinks'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  
  task :restart, roles: :app, except: { no_release: true } do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  desc 'Creates the symlinks for the shared folders'
  task :create_shared_symlinks, roles: :app, except: { no_release: true } do
    shared_paths = [['private'], ['config', 'app_config.yml']]

    shared_paths.each do |path|
      shared_files_path = File.join(shared_path, *path)
      release_files_path = File.join(release_path, *path)

      run "ln -s #{shared_files_path} #{release_files_path}"
    end
  end
end