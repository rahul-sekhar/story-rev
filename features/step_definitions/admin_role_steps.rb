Given /^the standard admin roles exist$/ do
  ar = Admin::Role.new
  ar.name = 'admin',
  ar.password = 'admin_pass'
  ar.save(validate: false)

  ar = Admin::Role.new
  ar.name = 'team',
  ar.password = 'team_pass'
  ar.save(validate: false)
end
