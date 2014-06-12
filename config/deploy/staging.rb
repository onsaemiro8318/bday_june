server 'm6.mnv.kr', user: 'onesup', roles: %w{web app db}# , my_property: :my_value
set :rails_env, :staging
set :application, 'bday_june_staging'
set :user, "deployer"
set :deploy_to, "/home/onesup/www/bday_june"
puts "deploy/staging.rb"