class AdminValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless Admin::Role.authenticate(value) == "admin"
      record.errors[attribute] << (options[:message] || "is not correct")
    end
  end
end