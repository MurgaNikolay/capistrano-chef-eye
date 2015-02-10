# Capistrano::Chef::Eye

[Chef Eye] (https://github.com/MurgaNikolay/chef-eye) plugin companion for [Capistrano]  (https://github.com/capistrano/capistrano).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-chef-eye'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-chef-eye

## Usage

Capfile

    require 'capistrano/chef_eye'
    
In command line:

    cap production eye:help

### Properties

    set :eye_roles, :all                       # Server roles, where eye is
    set :eye_strategy, :local                  # Eye strategy, :local or :system. Local is a eye daemon per project.
    set :eye_processes, [ :unicorn, :resque ]  # List of application processes
    set :eye_servers, -> {                     # List of servers fetched by roles.
      release_roles(fetch(:eye_roles))
    }
    set :eye_user, :auto                       # Eye service user. By default will fetched by `whoami`
    set :eye_helper_name, -> {                 # ye helper name
      fetch(:eye_strategy).to_s == 'local' ? "leye_#{fetch(:application)}" : "eye_#{fetch(:eye_user)}"
    }
    set :eye_service_name, -> {                # Name of int.d service
      fetch(:eye_strategy).to_s == 'local' ? "leye_#{fetch(:application)}" : "eye_#{fetch(:eye_user)}"
    }


The major property is:

  * `eye_processes`  this is the array of availables eye appplications processes. You need to set up it manualy.
  
### Available tasks

    cap eye:check                      
    cap eye:help                       # Show help
    cap eye:history
    cap eye:info   
    cap eye:processes                  # Show available process list and commands
    cap eye:reload                     
    cap eye:restart                    
    cap eye:start                      
    cap eye:stop                       
    cap eye:trace                      

## Contributing

1. Fork it ( https://github.com/[my-github-username]/capistrano-chef-eye/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
