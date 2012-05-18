namespace :backups do
  namespace :create do
    task :local do
      create_local_backup
    end
    
    namespace :remote do
        task :daily do
          num_remote = 7
          
          filename = create_remote_backup("daily")
          print_msg "Cleaning up local backups"
          Rake::Task['backups:cleanup'].invoke
          
          print_msg "Cleaning up remote daily backups"
          daily_backups = AWS::S3::Bucket.objects(app_settings['s3_backups_bucket'], :prefix => 'daily').map {|x| x.key}.sort{ |x,y| y <=> x }
          if daily_backups.length > num_remote
            print_msg "Keeping #{num_remote} out of #{daily_backups.length} remote backups"
            daily_backups[num_remote..(daily_backups.length - 1)].each do |key|
              AWS::S3::S3Object.delete key, app_settings['s3_backups_bucket']
            end
          else
            print_msg "No old remote backups to clean up"
          end
        end
        
        task :weekly do
          filename = create_remote_backup("weekly")
          print_msg "Removing the local copy"
          system "rm backups/#{filename}"
        end
        
        task :forced do
          filename = create_remote_backup("forced")
          print_msg "Removing the local copy"
          system "rm backups/#{filename}"
        end
        
        def create_remote_backup(folder_name)
          require 'aws/s3'
          
          filename = create_local_backup
          print_msg "Copying the backup to Amazon S3"
          
          AWS::S3::DEFAULT_HOST.replace app_settings['aws_domain']
          AWS::S3::Base.establish_connection!(
            :access_key_id     => sensitive_settings['aws_access_key_id'],
            :secret_access_key => sensitive_settings['aws_secret_access_key']
          )
          
          AWS::S3::S3Object.store("#{folder_name}/#{filename}", open("backups/#{filename}"), app_settings['s3_backups_bucket'])
          
          print_msg "Done!"
          return filename
        end
    end
    
    def create_local_backup
      print_msg "Creating a database copy"
      Rake::Task['db:data:dump'].invoke
      print_msg "Storing the database and shared assets in the backups folder"
      filename = "bak.#{Time.now.to_i}.tar.gz"
      sh "tar czhf backups/#{filename} db/data.yml #{app_settings['shared_assets'].join(" ")}"
      return filename
    end
  end
      
  task :cleanup do
    backup_files = %x[ls -xt backups].split(" ")
    num_local_backups = app_settings['num_local_backups']
    if backup_files.length > num_local_backups
      print_msg "Keeping #{num_local_backups} out of #{backup_files.length} backups"
      system "rm #{backup_files[num_local_backups..(backup_files.length - 1)].map{ |x| "backups/#{x}"}.join(" ")}"
    else
      print_msg "No old backups to clean up"
    end
  end
end

def app_settings
  @app_settings ||= YAML::load_file("config/settings.yml")
end

def sensitive_settings
  @sensitive_settings ||= YAML::load_file("config/sensitive.yml")
end

def print_msg(message)
  puts "#{Time.now.strftime("%d-%m-%y %T")} - #{message}"
end
  