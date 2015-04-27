require 'tempfile'
puts 'Get SSH config for vagrant'
file = Tempfile.new('vagrant')
file.write `vagrant ssh-config 2>/dev/null`
file.rewind

%w(web1 web2).each do |host|
  config = Net::SSH::Config.load(file.path, host)
  server(config['hostname'], port: config['port'], user: config['user'], roles: %w{web app}, ssh_options: {
      keys: config['identityfile'],
      forward_agent: false,
      auth_methods: %w(publickey)
    }) if config['hostname']
end

file.close
file.unlink

