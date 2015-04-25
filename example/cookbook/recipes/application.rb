
#cretae applications

include_recipe 'chef_eye::default'
include_recipe 'chef_eye::eye'

user = node['chef_eye_capistrano_example']['user']
app_name = "rails_sample"
ruby_rvm user do
  rubies '2.0.0'
end

%W(/var/www/#{app_name} /var/www/#{app_name}/shared /var/www/#{app_name}/config /var/www/#{app_name}/shared/log).each do |dir|
  directory dir do
    recursive true
    owner user
    group user
  end
end

bash "#{app_name}_bundle" do
  code <<EOF
/home/#{user}/.rvm/bin/rvm 2.0.0@default do gem install bundler
/home/#{user}/.rvm/bin/rvm 2.0.0@default do bundle install --jobs 2
EOF
  user user
  group user
  env 'HOME' => "/home/#{user}"
  cwd "/var/www/#{app_name}/current"
  action :nothing
end

git "/var/www/#{app_name}/current" do
  user user
  group user
  repository 'https://github.com/MurgaNikolay/rails-base.git'
  revision 'master'
  action :sync
  notifies :run, "bash[#{app_name}_bundle]", :immediately
end

chef_eye_application app_name do
  owner user
  group user
  config do
    working_dir "/var/www/#{app_name}/current"
    process 'unicorn' do
      pid_file 'tmp/pids/unicorn.pid'
      stdall 'log/eye.log'
      start_command "/home/#{user}/.rvm/bin/rvm 2.0.0@default do bundle exec unicorn_rails -D -E development -c config/unicorn.rb"
      stop_signals [:TERM, 10.seconds, :KILL]
      start_timeout 10
      restart_grace 10
      restart_command 'kill -USR2 {PID}'
      monitor_children do
        stop_command 'kill -QUIT {PID}'
        check :cpu, :every => 30, :below => 80, :times => 3
        check :memory, :every => 30, :below => 150.megabytes, :times => [3, 5]
      end
    end
  end
  if node['chef_eye_capistrano_example']['local']
    provider Chef::Provider::ChefEyeApplicationLocal
    eye_home "/var/www/#{app_name}/shared"
  else
    notifies :restart, "chef_eye_service[eye_#{user}]", :immediately
  end
  action :configure
end


