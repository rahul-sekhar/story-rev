module RupeeHelper
  def self.to_rupee(number)
    "Rs. #{number}"
  end
  
  def self.to_rupee_span(number)
    "<span class=\"rs\">Rs.</span> #{number}".html_safe
  end
  
  def self.format(number)
    if number
      string = number.to_s.split('.')
      number = string[0].gsub(/(\d+)(\d{3})$/){ p = $2;"#{$1.reverse.gsub(/(\d{2})/,'\1,').reverse},#{p}"}
      number = number.gsub(/^,/, '') + '.' + string[1] if string[1]
      # remove leading comma
      number = number[1..-1] if number[0] == ","
    end
    number
  end
  
  def self.format_rupee(number)
    self.to_rupee(self.format(number))
  end
end