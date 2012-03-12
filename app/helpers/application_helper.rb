module ApplicationHelper
  
  # Add parameters to the current URL
  def current_url(new_params)
    new_params = request.query_parameters.merge(new_params)
    request.url.split("?")[0] + "?" + new_params.map{ |k,v| "#{k}=#{v}" }.join("&")
  end
  
  # The more info menu items
  def more_nav_links
    {
      "books-special" => "Why we think these books are special",
      "condition" => "Condition of used books",
      "ordering" => "Ordering",
      "delivery" => "Delivery",
      "payment" => "Payment",
      "story-revolution" => "Story Revolution"
    }
  end
  
  def more_nav_selected
    @more_nav_selected ||= more_nav_links.has_key?(params["info"]) ? params[:info] : more_nav_links.first[0]
  end
  
  def class_if (condition, class_name)
    (' class="' + class_name + '"').html_safe if (condition)
  end
  
end
