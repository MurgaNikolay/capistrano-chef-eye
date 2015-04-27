# Usage example for chef_eye cookbook and capistrano chef_eye plugin

## Provision on virtualbox 

### Preapre 

- Install Vagrant
- Install Virtualbox
 
### Run and provision vagrant box with virtualbox provider

    cd application
    vagrant up
    cap staging eye:processes
    cap staging eye:info
    
    
        
## Provision on AWS 

### Setup vagrant 

    vagrant plugin install vagrant-aws
    vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box 
  
### Ser AWS config

    export AWS_ACCESS_KEY=AERTHMLP3VVFJ4MHFRG
    export AWS_SECRET_KEY= 34DFSC423FDS./+DDSC3WEFSDCDSVR#$R3442e32432
    export AWS_SESSION_TOKEN=
    export AWS_SSH_KEY_ID=test
    export AWS_DEFAULT_AMI=ami-7747d01e
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_USERNAME=ubuntu
    export AWS_PRIVATE_KEY=~/.ssh/test.pem

### Up and provision instances

    cd application
    vagrant up --provider=aws
    cap staging eye:processes
    cap staging eye:info


### Example for `local` eye strategy (leye per project)

Set `export EYE_LOCAL=true` before `vagrant up`. If you have provisioned boxes, destroy it before.


