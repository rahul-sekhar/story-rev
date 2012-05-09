AppSettings = YAML::load(File.open("config/settings.yml"))

namespace :backups do
    namespace :create do
        
        task :local do
            create_local_backup
        end
        
        namespace :remote do
            task :daily do
                num_remote = 7
                
                filename = create_remote_backup("daily")
                puts "- Cleaning up local backups"
                Rake::Task['backups:cleanup'].invoke
                
                puts "- Cleaning up remote daily backups"
                daily_backups = AWS::S3::Bucket.objects(AppSettings['s3_backups_bucket'], :prefix => 'daily').map {|x| x.key}.sort{ |x,y| y <=> x }
                if daily_backups.length > num_remote
                  puts "- Keeping #{num_remote} out of #{daily_backups.length} remote backups"
                  daily_backups[num_remote..(daily_backups.length - 1)].each do |key|
                    AWS::S3::S3Object.delete key, AppSettings['s3_backups_bucket']
                  end
                else
                  puts "- No old remote backups to clean up"
                end
            end
            
            task :weekly do
                filename = create_remote_backup("weekly")
                puts "- Removing the local copy"
                system "rm backups/#{filename}"
            end
            
            task :forced do
                filename = create_remote_backup("forced")
                puts "- Removing the local copy"
                system "rm backups/#{filename}"
            end
            
            def create_remote_backup(folder_name)
              require 'aws/s3'
              
              filename = create_local_backup
              puts "- Copying the backup to Amazon S3"
              
              AWS::S3::DEFAULT_HOST.replace AppSettings['aws_domain']
              AWS::S3::Base.establish_connection!(
                :access_key_id     => AppSettings['aws_access_key_id'],
                :secret_access_key => AppSettings['aws_secret_access_key']
              )
              
              AWS::S3::S3Object.store("#{folder_name}/#{filename}", open("backups/#{filename}"), AppSettings['s3_backups_bucket'])
              
              puts "- Done!"
              return filename
            end
        end
        
        def create_local_backup
            puts "- Creating a database copy"
            Rake::Task['db:data:dump'].invoke
            puts "- Storing the database and shared assets in the backups folder"
            filename = "bak.#{Time.now.to_i}.tar.gz"
            sh "tar czhf backups/#{filename} db/data.yml #{AppSettings['shared_assets'].join(" ")}"
            return filename
        end
    end
        
    task :cleanup do
        backup_files = %x[ls -xt backups].split(" ")
        num_local_backups = AppSettings['num_local_backups']
        if backup_files.length > num_local_backups
          puts "- Keeping #{num_local_backups} out of #{backup_files.length} backups"
          system "rm #{backup_files[num_local_backups..(backup_files.length - 1)].map{ |x| "backups/#{x}"}.join(" ")}"
        else
          puts "- No old backups to clean up"
        end
    end
end
    