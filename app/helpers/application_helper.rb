module ApplicationHelper
  
  # Add parameters to the current URL
  def current_url(new_params, element_id = nil)
    new_params = request.query_parameters.merge(new_params)
    request.url.split("?")[0] + "?" + new_params.map{ |k,v| "#{k}=#{v}" }.join("&") + (element_id ? "##{element_id}" : "")
  end
  
  def sort_url(param)
    new_params = request.query_parameters.merge({:sort => param})
    new_params.delete(:page)
    store_path(new_params, :anchor => "products")
  end
  
  def filter_url(new_params, element_id = "products")
    require "addressable/uri"
    uri = Addressable::URI.new
    
    filters = %w[condition price content_type product_type collection age_to age_from search type format sort price_range price_from price_to]
    
    filter_params = {}
    filters.each do |f|
      filter_params[f.to_sym] = params[f] if params[f].present?
    end
    
    new_params = filter_params.merge(new_params)
    uri.query_values = new_params
    request.url.split("?")[0] + "?" + uri.query + (element_id ? "##{element_id}" : "")
  end
  
  def switch_collection_path(new_params = {})
    store_path({:anchor => "products"}.merge(new_params))
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
  
  def filter_box (attr, val)
    check_box_tag("#{attr}[#{val}]", "1", (params[attr.to_s] && params[attr.to_s][val.to_s])).html_safe
  end
end
