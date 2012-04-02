module RupeeHelper
  def self.to_rupee(number)
    "Rs. #{number}"
  end
  
  def self.to_rupee_span(number)
    "<span class=\"rs\">Rs.</span> #{number}".html_safe
  end
end