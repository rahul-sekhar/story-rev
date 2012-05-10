# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "log/cron.log"

job_type :runner,  "cd :path && bundle exec rails runner -e :environment ':task' :output"

# Daily backup
every 1.day, :at => '4:00 am' do
  rake "backups:create:remote:daily"
end

# Weekly backup
every :friday, :at => '4:30 am' do
  rake "backups:create:remote:weekly"
end

# Cron jobs
every :thursday, :at => '9:40 am' do
  runner "CoverImage.clear_old"
  runner "ShoppingCart.clear_old"
  runner "Order.clear_old"
end