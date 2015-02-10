namespace :eye do
  desc 'Show help'
  task :help do
    puts <<-EOF
set :eye_roles, :all                       # Server roles, where eye is
set :eye_strategy, :local                  # Eye strategy, :local or :system. Local is a eye daemon per project.
set :eye_servers, -> {                     # List of servers fetched by roles.
  release_roles(fetch(:eye_roles))
}
set :eye_processes, [ ]                    # List of application processes, for example: [ :unicorn, :resque ]
set :eye_user, :auto                       # Eye service user. By default will fetched by `whoami`
set :eye_helper_name, -> {                 # ye helper name
  fetch(:eye_strategy).to_s == 'local' ? "leye_\#{fetch(:application)}" : "eye_\#{fetch(:eye_user)}"
}
set :eye_service_name, -> {                # Name of int.d service
  fetch(:eye_strategy).to_s == 'local' ? "leye_\#{fetch(:application)}" : "eye_\#{fetch(:eye_user)}"
}
    EOF
  end
  commands = [:start, :restart, :stop, :history, :check, :info, :trace, :reload]

  task :hook do
    fetch(:eye_processes).each do |process|
      commands.each do |command|
        Rake::Task.define_task("eye:#{command}:#{process}") do
          eye_execute_helper(command, process)
        end
      end
    end
  end

  desc 'Show available process list and commands'
  task :processes do
    fetch(:eye_processes).each do |process|
      puts "#{process}".bold.yellow
      commands.each do |command|
        puts "  cap eye:#{process.to_s.yellow}:#{command}"
      end
    end

  end

  commands.each do |command|
    desc command.to_s
    task command do
      eye_execute_helper(command)
    end
  end

  #after 'deploy:restart', 'chef_eye:reload'
end

Capistrano::DSL.stages.each do |stage|
  after stage, 'eye:hook'
end

namespace :load do
  task :defaults do
    set :eye_roles, :all
    set :eye_strategy, :local #or global
    set :eye_servers, -> { release_roles(fetch(:eye_roles)) }
    set :eye_processes, [ ]
    set :eye_user, -> { 'auto' }
    set :eye_helper_name, -> {
      fetch(:eye_strategy).to_s == 'local' ? "leye_#{fetch(:application)}" : "eye_#{fetch(:eye_user)}"
    }
    set :eye_service_name, -> {
      fetch(:eye_strategy).to_s == 'local' ? "leye_#{fetch(:application)}" : "eye_#{fetch(:eye_user)}"
    }
    set :eye_helper, -> {
      "/usr/local/sbin/#{fetch(:eye_helper_name)}"
    }
    set :eye_service, -> {
      "/etc/init.d/#{fetch(:eye_service_name)}"
    }
  end
end

def eye_execute_helper(command, mask='')
  on fetch(:eye_servers) do
    auto = fetch(:eye_user) == 'auto'
    set :eye_user, capture('whoami') if auto
    begin
      result = capture fetch(:eye_helper), command, mask
      puts result unless fetch(:format) == :pretty
    rescue Exception => e
      # puts e.message
    end
    set :eye_user, 'auto' if auto
  end
end
