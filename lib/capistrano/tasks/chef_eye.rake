namespace :eye do
  desc 'Show help'
  task :help do
    puts <<-EOF
set :eye_application_name, :my_application # Server roles, where eye is
set :eye_roles, :all                       # Server roles, where eye is
set :eye_type, :local                  # Eye strategy, :local or :system. Local is a eye daemon per project.
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
set :eye_home, -> {
}

set :eye_file, -> {
}
    EOF
  end
  commands = [:start, :restart, :stop, :history, :check, :info, :trace]

  task :hook do
    processes = fetch(:eye_processes)
    output = SSHKit.config.output
    SSHKit.config.format= :dot
    processes ||= begin
      r = eye_execute('info')
      r.map! do |info|
        info.split("\n").map! do |i|
          Array(i.match(/^\s\s(\S+)/))[1]
        end
      end.flatten!.compact!.uniq
    end
    SSHKit.config.output = output
    set(:eye_processes, processes)
    processes.each do |process|
      commands.each do |command|
        Rake::Task.define_task("eye:#{process}:#{command}") do
          process = "#{fetch(:eye_application)}:#{process}" unless fetch(:eye_strategy) == 'local'
          eye_execute(command, process)
        end
      end
    end
  end

  desc 'Show available process list and commands'
  task :processes do
    fetch(:eye_processes).each do |process|
      puts "#{process}".bold.yellow
      commands.each do |command|
        puts "cap eye:#{process.to_s.yellow}:#{command}"
      end
    end
  end

  commands.each do |command|
    desc command.to_s
    task command do
      eye_execute(command, fetch(:eye_application))
    end
  end

  desc 'Reload configuration'
  task :reload, :load do
    eye_execute(:load, fetch(:eye_file))
  end

  after 'deploy:restart', 'eye:restart'
end

Capistrano::DSL.stages.each do |stage|
  after stage, 'eye:hook'
end

namespace :load do
  task :defaults do
    set :eye_strategy, 'local'
    set :eye_application, -> { fetch(:application) }
    set :eye_type, :local #or global
    set :eye_roles, :all
    set :eye_servers, -> { release_roles(fetch(:eye_roles)) }
    set :eye_processes, nil
    set :eye_user, -> { 'auto' }
    set :eye_file, -> {
      if fetch(:eye_strategy).to_s == 'local'
        'Eyefile'
      else
        "/etc/eye/{eye_user}/#{fetch(:eye_application)}.eye"
      end
    }
    set :eye_home, -> {
      if fetch(:eye_strategy).to_s == 'local'
        "#{shared_path}"
      else
        "#{fetch(:deploy_to)}"
      end
    }

    set :eye_bin, -> {
      if fetch(:eye_strategy).to_s == 'local'
        '/usr/local/bin/leye'
      else
        '/usr/local/bin/eye'
      end
    }
  end
end

def eye_execute(command, mask='')
  res = []
  rvm_path = fetch(:rvm_path)
  eye_bin = fetch(:eye_bin)
  eye_bin = "#{rvm_path}/bin/rvm system do #{eye_bin}" if rvm_path
  cmd = "#{eye_bin} #{command} #{mask}".strip

  on fetch(:eye_servers) do
    begin
      within fetch(:eye_home) do
        cmd.gsub!('{eye_user}', capture('whoami'))
        result = capture(*cmd.split(' '))
        res << result
        # puts result unless fetch(:format) == :pretty
      end
    rescue Exception => e
      # puts e.message
    end
  end
  res
end
