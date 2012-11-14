module FindableByName
  def name_is(data)
    where{name.like(data)}.first
  end
  
  def name_like(data)
    data = "%#{SqlHelper::escapeWildcards(data)}%"
    where{name.like(data)}
  end
end