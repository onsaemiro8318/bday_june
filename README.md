```

bundle exec cap install
edit Capfile
bundle exec rails generate rspec:install
rm -rf test
bundle exec guard init
mkdir lib/capistrano/templates
cd ./lib/capistrano/templates
vi database_yml.erb
vi nginx_conf.erb
vi nginx_site.erb
vi unicorn_init.erb
vi unicorn.rb.erb
cd ./lib/capistrano/tasks
vi nginx_unicorn.cap
vi utility.cap
cd ./config
vi deploy.rb
cd ./config/deploy
vi production.rb
vi staging.rb
set :ssh_options, {keys: %w(/Users/onesup/.ssh/ids/bday.mnv.kr/deployer/id_rsa)}
cd ./
vi .gitignore
```