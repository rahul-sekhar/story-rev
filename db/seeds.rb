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

if (PickupPoint.count == 0)
  puts "\nCreating pickup points"
  puts "======================"
  
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
end

puts "\nCreating Content Types"
puts "======================"

content_types = %w[Fiction Non-fiction In-between]

puts "Clearing first three types"
ContentType.where(:id => (1..3)).all.each {|x| x.delete}
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
puts "Resetting primary key sequence"
SqlHelper.reset_primary_key(ContentType)

puts "\nCreating English as the default language"
puts "========================================"

Language.where(:id => 1).each {|x| x.delete}
Language.where(:name => "English").each {|x| x.destroy}

lang = Language.new(:name => "English")
lang.id = 1

if lang.save
  puts "Done"
else
  puts "Failed"
end

puts "\nCreating default accounts and setting config data"
puts "=================================================="

config = ConfigData.access

if config.cash_account.present?
  puts "Cash account already exists - #{config.cash_account.name}"
else
  cash_account = Account.find_by_name("Unaccounted")
  if cash_account
    puts "Cash account named 'Unaccounted' already exists, using it"
  else
    puts "Creating a cash account named 'Unaccounted'"
    cash_account = Account.create(:name => "Unaccounted")
  end
  config.cash_account = cash_account
end

if config.default_account.present?
  puts "Default account already exists - #{config.default_account.name}"
else
  if Account.count > 1
    default_account = Account.where("id <> ?", config.cash_account.id).first
    puts "Setting default account to - #{default_account.name}"
  else
    puts "Creating a default account named 'Default'"
    default_account = Account.create(:name => "Default")
  end
  config.default_account = default_account
end

config.save

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

puts "\nCreating transaction categories"
puts "================================"

categories = ["Online order", "Postage expenditure"]

puts "Clearing first two methods"
TransactionCategory.where(:id => (1..2)).all.each {|x| x.delete}
TransactionCategory.where(:name => categories).all.each {|x| x.destroy}

i = 0
categories.each do |x|
  i += 1
  category = TransactionCategory.new(:name => x)
  category.id = i
  if category.save
    puts "Created: #{x} [id: #{i}]"
  else
    puts "Failed: #{x}"
  end
end

puts "Resetting primary key sequence"
SqlHelper.reset_primary_key(TransactionCategory)

puts "\nCreating transfer categories"
puts "================================"

if TransferCategory.count > 0
  puts "Transfer categories already exist, leaving them alone"
else
  puts "No transfer categories exist - creating an 'Account Transfer' category"
  TransferCategory.create(name: 'Account Transfer')
end

puts "Done"