# Capistrano eye extension

[Chef Eye] (https://github.com/MurgaNikolay/chef-eye) cookbook companion for [Capistrano]  (https://github.com/capistrano/capistrano).

[![GitHub version](https://badge.fury.io/gh/MurgaNikolay%2Fcapistrano-chef-eye.svg)](http://badge.fury.io/gh/MurgaNikolay%2Fcapistrano-chef-eye)
[![Code Climate](https://codeclimate.com/github/MurgaNikolay/capistrano-chef-eye/badges/gpa.svg)](https://codeclimate.com/github/MurgaNikolay/capistrano-chef-eye)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-chef-eye'
```

And then execute:

```bash
$ bundle
```
Or install it yourself as:

```bash
$ gem install capistrano-chef-eye
```

## Usage

Capfile

```ruby
require 'capistrano/chef_eye'
```    
In command line:

    cap production eye:help
    cap production eye:processes # List of commands per processes

### Properties

```ruby
set :eye_strategy, 'local'  # chef_eye strategy. 'local' or 'user'
set :eye_application, -> { fetch(:application) } # eye application name. Used for generate path to eye file, and service name
set :eye_roles, :all
set :eye_servers, -> { release_roles(fetch(:eye_roles)) } # Servers with eye. Fetched by eye_roles
set :eye_processes, nil # List of eye processes. Library try to detect processes automatically, if nil
set :eye_user, -> { 'auto' } # Owner of eye process
set :eye_file, -> { # Path to eye application config
  if fetch(:eye_strategy).to_s == 'local'
    'Eyefile'
  else
    "/etc/eye/{eye_user}/#{fetch(:eye_application)}.eye"
  end
}
set :eye_home, -> { # Path to eye home. 
  if fetch(:eye_strategy).to_s == 'local'
    "#{shared_path}"
  else
    "#{fetch(:deploy_to)}"
  end
}

set :eye_bin, -> {  # Path to eye bin
  if fetch(:eye_strategy).to_s == 'local'
    '/usr/local/bin/leye'
  else
    '/usr/local/bin/eye'
  end
}
```
The major property is:

  * `eye_processes`  this is the array of availables eye appplications processes. You need to set up it manualy.
  
### Available tasks

    cap eye:check                      # Check configuration
    cap eye:help                       # Show help
    cap eye:history                    # Show monitoring history
    cap eye:info                       # Current process status
    cap eye:processes                  # Show available process list and commands
    cap eye:reload                     # Reload configuration
    cap eye:restart                    # Restart all processes
    cap eye:force_restart              # Force restart all processes (stop and start)
    cap eye:start                      # Start all processes
    cap eye:stop                       # Stop all processes
    cap eye:trace                      # Trace log for application

## Example 
  
See [example/README.md](example/README.md) 


# TODO 

  - Set processes per roles
  - Something else :)
   
## Contributing

1. Fork it ( https://github.com/[my-github-username]/capistrano-chef-eye/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
