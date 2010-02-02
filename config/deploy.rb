default_run_options[:pty] = true

set :application, "droplet"
set :repository, "git@github.com:adamelliot/droplet.git"
set :user, 'deploy'
set :scm, 'git'

set :branch, "origin/master"

set :deploy_via, :remote_cache
set :git_shallow_clone, 1

set :apache_site_folder, "/etc/apache2/sites-enabled"
set :use_sudo, true

role :web, "icarus.warptube.com"
role :app, "icarus.warptube.com"
role :db,  "icarus.warptube.com", :primary => true # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

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
  ServerName #{application}
  #{"ServerAlias #{server_alias}" if exists?(:server_alias)}
  DocumentRoot "#{base_path}/#{application}/current/public"
  RailsEnv production
  RailsAllowModRewrite off
  <directory "#{base_path}/#{application}/current/public">
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

namespace :init do
  desc "setting proper permissions for deploy user"
  task :set_permissions do
    sudo "chmod -R g+rw #{base_path}/#{application}"
    sudo "chown -R #{user}:admin #{base_path}/#{application}"
  end

end
