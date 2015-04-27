
include_recipe 'apt'
package 'build-essential'
package 'nodejs-legacy'
package 'git'
package 'curl'

include_recipe 'chef_eye_capistrano_example::application'
