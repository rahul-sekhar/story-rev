module ApplicationHelper
  
  # Add parameters to the current URL
  def current_url(new_params, element_id = nil)
    new_params = request.query_parameters.merge(new_params)
    request.url.split("?")[0] + "?" + new_params.map{ |k,v| "#{k}=#{v}" }.join("&") + (element_id ? "##{element_id}" : "")
  end
  
  def sort_params
    %w[sort_by desc seed]
  end
  
  def base_filters
    %w[search collection recent award_winning]
  end
  
  def filters
    %w[type category age condition format price price_from price_to]
  end
  
  def filter_name (name, val)
    case name.to_s
    when "search"
      "Search \"#{val}\""
    when "recent"
      "Newest Additions"
    when "award_winning"
      "Award winning"
    when "collection"
      Collection.find_by_id(val).name || ""
    when "author"
      Author.find_by_id(val).full_name || ""
    when "illustrator"
      Illustrator.find_by_id(val).full_name || ""
    when "publisher"
      Publisher.find_by_id(val).name || ""
    when "award"
      AwardType.find_by_id(val).name || ""
    when "condition"
      "Condition - #{val} stars#{val.to_i == 5 ? "" : " or above"}"
    when "category"
      ProductType.find_by_id(val).name || ""
    when "age"
      "Age #{val}"
    when "type"
      val == "new" ? "New books" : "Used books"
    when "format"
      Format.find_by_id(val).name || ""
    else
      "All books"
    end
  end
    
  def price_name
    price = params[:price]
    price_from = params[:price_from]
    price_to = params[:price_to]
    
    if price.present? && price_from.blank? && price_to.blank?
      a = price.split("-").map{|x| x.to_i}
      if a.length == 2
        price_from = a.min
        price_to = a.max
      else
        price_from = a[0]
      end
    end
    
    if price_from.to_i > 0 && price_to.to_i > 0
      "Price - #{RupeeHelper.to_rupee_span(price_from)} to #{RupeeHelper.to_rupee_span(price_to)}".html_safe
    elsif price_from.to_i > 0
      "Price - more than #{RupeeHelper.to_rupee_span(price_from)}".html_safe
    else
      "Price - less than #{RupeeHelper.to_rupee_span(price_to)}".html_safe
    end
  end
  
  def filter_list
    list = {}
    filters.each do |f|
      list[f] = params[f] if params[f].present?
    end
    
    return list
  end
  
  def get_base
    base_filters.each do |f|
      return f if params[f].present?
    end
    return nil
  end
  
  def applied_filters
    result = []
    
    filters.each do |f|
      result << f if params[f].present?
    end
    return result
  end
  
  def sort_path(name)
    link_params = {}
    
    base_filters.each do |f|
      if params[f].present?
        link_params[f] = params[f]
        break
      end
    end
    
    filters.each do |f|
      if params[f].present?
        link_params[f] = params[f]
      end
    end
    
    if (params[:sort_by].to_s == name.to_s) && params[:desc].blank? && name.to_s != "random"
      link_params[:desc] = 1
    end
    
    link_params[:sort_by] = name
    root_path(link_params, :anchor => "products")
  end
  
  def collection_params(name, val)
    link_params = {}
    
    sort_params.each do |s|
      link_params[s] = params[s] if params[s].present?
    end
    
    link_params[name] = val if val
    return link_params
  end
  
  def collection_path(name, val)
    root_path(collection_params(name, val), :anchor => "products")
  end
  
  def filter_params(name, val)
    link_params = {}
    
    sort_params.each do |s|
      link_params[s] = params[s] if params[s].present?
    end
    
    base_filters.each do |f|
      if params[f].present?
        link_params[f] = params[f]
        break
      end
    end
    
    filters.each do |f|
      next if (name.to_s == "price" && %w[price_from price_to].include?(f))
      if (f != name.to_s) && params[f].present?
        link_params[f] = params[f]
      end
    end
    
    link_params[name] = val if val
    
    return link_params
  end
  
  def filter_path(name, val)
    root_path(filter_params(name, val), :anchor => "products")
  end
  
  def sort_link(name)
    attr = name
    klass = nil
    
    if (params[:sort_by].to_s == attr.to_s)
      klass = "current"
      klass += params[:desc].blank? ? " asc" : " desc" unless name.to_s == "random"
    end
    
    link_to(name, sort_path(attr), :class => klass)
  end
  
  def collection_link(text, name, val)
    val = val.to_s if val.is_a? Integer
    link_to(text, collection_path(name, val), :class => (params[name] == val ? "current" : nil))
  end
  
  def filter_link(text, name, val)
    val = val.to_s if val.is_a? Integer
    link_to(text, filter_path(name, val), :class => (params[name] == val ? "current" : nil))
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
