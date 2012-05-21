# RVM
require "rvm/capistrano"
set :rvm_ruby_string, '1.9.3-p194@story-rev'
set :rvm_type, :system

# Bundler
require "bundler/capistrano"

set :application, "story-rev"

default_run_options[:pty] = true
set :repository,  "git@github.com:rahul-sekhar/story-rev.git"
set :scm, :git
set :scm_passphrase, YAML::load_file("config/sensitive.yml")['scm_pass']

set :user, "rahul"
set :use_sudo, false
set :deploy_to, "/home/#{user}/#{application}"
set :host_name, "storyrevolution.in"
server host_name, :app, :web, :db, :primary => true

# App config settings
set :app_settings, YAML::load_file("config/settings.yml")

# Delayed job
require "delayed/recipes"
set :rails_env, "production" #added for delayed job
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

# Whenever cron jobs
set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"


# Sensitive data
namespace :sensitive_data do
  
  desc "Copies the sensitive.yml file to the server"
  task :setup, :roles => [:app, :web] do
    run "mkdir -p #{shared_path}/config"
    upload("config/sensitive.yml", "#{shared_path}/config/sensitive.yml")
  end
  
  desc "Updates symlinks for the sensitive.yml file"
  task :update_symlinks, :roles => [:app, :web] do
    run "ln -nfs #{shared_path}/config/sensitive.yml #{release_path}/config/sensitive.yml"
  end
end

after "deploy:assets:symlink", "sensitive_data:update_symlinks"


# Database
namespace :db do
  desc "Import the database from the remote server to the local machine"
  task :import_from_remote, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production rake db:data:dump"
    get "#{current_path}/db/data.yml", "db/data.yml"
    puts "* importing the database"
    system "rake db:data:load"
    puts "* done!"
  end
  
  desc "Export the database from the local machine to the remote server"
  task :export_to_remote, :roles => :app do
    system "rake db:data:dump"
    upload "db/data.yml", "#{current_path}/db/data.yml"
    puts "* exporting the database"
    run "cd #{current_path} && RAILS_ENV=production rake db:data:load"
    puts "* done!"
  end
  
  desc "Seed the database"
  task :seed, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production rake db:seed"
    puts "* done!"
  end
  
  desc "Load the schema"
  task :schema_load, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production rake db:schema:load"
    puts "* done!"
  end
end


# Shared assets
set :shared_asset_paths, app_settings['shared_assets']

namespace :shared_assets  do
  namespace :symlinks do
    desc "Setup application symlinks for shared assets"
    task :setup, :roles => [:app, :web] do
      shared_asset_paths.each { |link| run "mkdir -p #{shared_path}/#{link}" }
    end

    desc "Link assets for current deploy to the shared location"
    task :update, :roles => [:app, :web] do
      shared_asset_paths.each { |link| run "ln -nfs #{shared_path}/#{link} #{release_path}/#{link}" }
    end
  end
  
  desc "Import shared objects from the remote server to the local machine"
  task :import, :roles => :app do
    shared_asset_paths.each do |link|
      system "rsync -rP #{user}@#{host_name}:#{shared_path}/#{link} #{link}/.."
    end
  end
end

before "deploy:setup", "shared_assets:symlinks:setup"
before "deploy:create_symlink", "shared_assets:symlinks:update"

# Backups
set :backup_path, "#{deploy_to}/backups"

namespace :backups do
  desc "Setup the backup environment"
  task :setup, :roles => :app do
    run "mkdir -p #{backup_path}"
  end
  
  desc "Update backup symlink"
  task :update_symlink, :roles => :app do
    run "ln -nfs #{backup_path} #{release_path}/backups"
  end
  
  namespace :create do
    desc "Create a daily local and remote backup"
    task :default, :roles => :app do
      run "cd #{current_path} && RAILS_ENV=production rake backups:create:remote:daily"
    end
    
    desc "Create a forced remote backup"
    task :remote, :roles => :app do
      run "cd #{current_path} && RAILS_ENV=production rake backups:create:remote:forced"
    end
    
    desc "Create a local backup"
    task :local, :roles => :app do
      run "cd #{current_path} && RAILS_ENV=production rake backups:create:local"
    end
  end
  
  desc "Clean up old local backups"
  task :cleanup, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production rake backups:cleanup"
  end
  
  desc "Import backups to the local machine"
  task :sync, :roles => :app do
    system "rsync -rP #{user}@#{host_name}:#{backup_path} ."
  end
end

before "deploy:setup", "backups:setup"
before "deploy:create_symlink", "backups:update_symlink"
after "deploy:cleanup", "backups:cleanup"


# Logs
set :log_names, %w{production cron store}

namespace :logs do
  desc "Setup logs"
  task :setup, :roles => :app do
    run "mkdir -p #{shared_path}/log"
    log_names.each do |log_name|
      run "touch #{shared_path}/log/#{log_name}.log"
    end
  end
  
  namespace :tail do
    log_names.each do |log_name|
      desc "Tail #{log_name} log files" 
      task log_name, :roles => :app do
        run "tail -f #{shared_path}/log/#{log_name}.log" do |channel, stream, data|
          trap("INT") { puts 'Interupted'; exit 0; } 
          puts  # for an extra line break before the host name
          puts "#{channel[:host]}: #{data}" 
          break if stream == :err
        end
      end
    end
  end
end

before "deploy:setup", "logs:setup"


# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
