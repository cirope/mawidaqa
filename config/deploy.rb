require 'bundler/capistrano'
require 'sidekiq/capistrano'

set :application, 'mawidaqa'
set :repository,  'https://github.com/francocatena/mawidaqa.git'
set :deploy_to, '/var/rails/mawidaqa'
set :user, 'deployer'
set :group_writable, false
set :shared_children, %w(log)
set :use_sudo, false

set :scm, :git
set :branch, 'master'

role :web, 'mawidaqa.com'
role :app, 'mawidaqa.com'
role :db, 'mawidaqa.com', primary: true

before 'deploy:finalize_update', 'deploy:create_shared_symlinks'
after 'deploy:update_code', 'deploy:create_tmp_pids_symlink'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  
  task :restart, roles: :app, except: { no_release: true } do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  desc 'Creates the symlinks for the shared folders'
  task :create_shared_symlinks, roles: :app, except: { no_release: true } do
    shared_paths = [['config', 'app_config.yml']]

    shared_paths.each do |path|
      shared_files_path = File.join(shared_path, *path)
      release_files_path = File.join(release_path, *path)

      run "ln -s #{shared_files_path} #{release_files_path}"
    end
  end

  desc 'Creates the synmlink to tmp/pids'
  task :create_tmp_pids_symlink, roles: :app, except: { no_release: true } do
    run "mkdir -p #{release_path}/tmp"
    run "mkdir -p #{shared_path}/tmp/pids"
    run "ln -s #{shared_path}/tmp/pids #{release_path}/tmp/pids"
  end
end
