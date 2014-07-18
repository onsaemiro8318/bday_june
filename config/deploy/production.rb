server 'm4.mnv.kr', user: 'deployer', roles: %w{web app db}# , my_property: :my_value
set :ssh_options, {
  keys: %w(/Users/minivertising/.ssh/ids/m4.mnv.kr/deployer/id_rsa),
  forward_agent: false
  # use_agent: false
  # auth_methods: %w(password)
}
set :rails_env, :production
set :application, 'bday_june'
set :user, "deployer"
set :deploy_to, "/home/deployer/www/bday_june"
puts "deploy/production.rb"