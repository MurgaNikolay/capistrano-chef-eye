# config valid only for Capistrano 3.1
lock '3.4.0'

set :application, 'rails_sample'
set :repo_url, 'https://github.com/MurgaNikolay/rails-base.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
set :eye_strategy, ENV['EYE_LOCAL'] ? 'local' : 'user'
# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/rails_sample'
set :rvm_ruby_version, '2.0.0@default'      # Defaults to: 'default'
set :pty, false
# set :eye_processes, %w(unicorn)
# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 3

namespace :deploy do
  desc 'Restart unicorn'
  task :restart do
    invoke 'eye:unicorn:restart'
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end
