default_run_options[:pty] = true

set :application, "droplet"
set :repository, "git@github.com:adamelliot/droplet.git"
set :user, 'deploy'
set :scm, 'git'

set :server_name, "#{application}.warptube.com"

set :branch, "origin/master"

set :deploy_via, :remote_cache
set :git_shallow_clone, 1

set :apache_site_folder, "/etc/apache2/sites-enabled"
set :use_sudo, true

role :web, "icarus.warptube.com"
role :app, "icarus.warptube.com"
role :db,  "icarus.warptube.com", :primary => true

after "deploy:setup", "config:set_permissions"
after "deploy:setup", "config:create_config_yaml"
after "deploy:setup", "db:auto_migrate"
after "deploy:setup", "apache:create_vhost"
after "deploy:setup", "apache:enable_site"
after "deploy:setup", "apache:reload_apache"
after "deploy:setup", "deploy"
after "deploy", "deploy:restart"

after "deploy:update_code", "config:copy_shared_configurations"

namespace :deploy do
  [:start, :restart].each do |t|
    desc "Restarting mod_rails with restart.txt"
    task t, :roles => :app, :except => {:no_release => true} do
      run "touch #{current_path}/tmp/restart.txt"
    end
  end

  desc "Stop task is a no-op with mod_rails"
  task :stop, :roles => :app do ; end
end

namespace :apache do
  desc "reloads apache configuration to make site active"
  task :reload_apache do
    sudo "/etc/init.d/apache2 reload"
  end

  desc "enable site"
  task :enable_site do
    sudo "ln -nsf #{shared_path}/config/apache_site.conf #{apache_site_folder}/#{application}"
  end

  desc "disable site"
  task :disable_site do
    sudo "rm #{apache_site_folder}/#{application}"
  end

  desc "create vhost file"
  task :create_vhost do
    vhost_configuration = <<-VHOST
<VirtualHost *:80>
  ServerName #{server_name}
  #{"ServerAlias #{server_alias}" if exists?(:server_alias)}
  DocumentRoot "#{deploy_to}/current/public"
  RailsEnv production
  RailsAllowModRewrite off
  <directory "#{deploy_to}/current/public">
    Order allow,deny
    Allow from all
  </directory>
  ExpiresActive On
  ExpiresDefault "access plus 30 days"
</VirtualHost>
VHOST

    put vhost_configuration, "#{shared_path}/config/apache_site.conf"
  end
end

namespace :db do
  desc "Runs the auto migration for datamapper (dumps data)"
  task :auto_migrate do
    run("cd #{current_path}; rake db:migrate RAILS_ENV=#{rails_env}")
  end
end

namespace :config do
  desc "setting proper permissions for deploy user"
  task :set_permissions do
    sudo "chmod -R g+rw #{deploy_to}"
    sudo "chown -R #{user}:admin #{deploy_to}"
  end

  desc "copy shared configurations to current"
  task :copy_shared_configurations, :roles => [:app] do
    %w[config.yml db.sqlite3].each do |f|
      run "ln -nsf #{shared_path}/config/#{f} #{release_path}/config/#{f}"
    end
    
    run "mkdir -p #{shared_path}/system"
    run "ln -nsf #{shared_path}/system #{release_path}/public/system"
  end

  desc "Update the facebooker.yml"
  task :create_config_yaml do
    set(:password) do
      Capistrano::CLI.password_prompt("Droplet upload password (username is 'droplet'): ")
    end unless exists?(:password)
    
    config = <<-CONFIG_YML
password: #{password}
CONFIG_YML
    run "mkdir -p #{shared_path}/config"
    put config, "#{shared_path}/config/config.yml"
  end
end
