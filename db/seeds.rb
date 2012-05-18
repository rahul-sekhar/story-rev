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

puts "\nCreating pickup points"
puts "======================"
puts "Clearing old points"
PickupPoint.all.each { |x| x.destroy }

pickup_points = [
  "Banashankari 2nd Stage",
  "Jayanagar"
]

pickup_points.each do |p|
  if PickupPoint.create(:name => p)
    puts "Created: #{p}"
  else
    puts "Failed: #{p}"
  end
end

puts "\nCreating Content Types"
puts "======================"

content_types = %w[Fiction Non-fiction In-between]

puts "Clearing first three types"
ContentType.where(:id => (1..3)).all.each {|x| x.destroy}
ContentType.where(:name => content_types).all.each {|x| x.destroy}

i = 0
content_types.each do |c|
  i += 1
  content_type = ContentType.new(:name => c)
  content_type.id = i
  if content_type.save
    puts "Created: #{c}"
  else
    puts "Failed: #{c}"
  end
end

puts "\nCreating English as the default language"
puts "========================================"

Language.where(:id => 1).each {|x| x.destroy}
Language.where(:name => "English").each {|x| x.destroy}

lang = Language.new(:name => "English")
lang.id = 1
lang.save

puts "Done"