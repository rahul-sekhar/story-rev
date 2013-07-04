set :output, "log/cron.log"

job_type :runner,  "cd :path && bundle exec rails runner -e :environment ':task' :output"
job_type :envcommand, 'cd :path && RAILS_ENV=:environment :task'

# Start delayed job on reboot
every :reboot do
  envcommand 'script/delayed_job restart'
end

# Daily backup
every 1.day, :at => '4:00 am' do
  rake "backups:create:remote:daily"
end

# Weekly backup
every :friday, :at => '4:30 am' do
  rake "backups:create:remote:weekly"
end

# Cron jobs
every :thursday, :at => '4:30 am' do
  runner "CoverImage.clear_old"
  runner "Order.clear_old"
end

