module FindableByName
  def name_is(data)
    where("LOWER(name) = ?", data.downcase).first
  end
  
  def name_like(data)
    where("LOWER(name) LIKE ?", 
      "%#{SqlHelper::escapeWildcards(data.downcase)}%")
  end
end