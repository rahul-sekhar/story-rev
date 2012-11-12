puts "\nCreating admin roles"
puts "===================="
Admin::Role.all.each {|x| x.destroy }

ar = Admin::Role.new
ar.name = "admin"
ar.password = Rails.configuration.sensitive['default_admin_pass']
if (ar.save(:validate => false))
  puts "Created: 'admin'"
else
  puts "Failed: 'admin'"
end

ar = Admin::Role.new
ar.name = "team"
ar.password = Rails.configuration.sensitive['default_team_pass']
if (ar.save(:validate => false))
  puts "Created: 'team'"
else
  puts "Failed: 'team'"
end


puts "\nCreating payment methods"
puts "========================="

methods = ["Bank transfer", "Cheque", "Cash"]

puts "Clearing first three methods"
PaymentMethod.where(:id => (1..3)).all.each {|x| x.delete}
PaymentMethod.where(:name => methods).all.each {|x| x.destroy}

i = 0
methods.each do |x|
  i += 1
  method = PaymentMethod.new(:name => x)
  method.id = i
  if method.save
    puts "Created: #{x} [id: #{i}]"
  else
    puts "Failed: #{x}"
  end
end
puts "Resetting primary key sequence"
SqlHelper.reset_primary_key(PaymentMethod)


puts "Done"