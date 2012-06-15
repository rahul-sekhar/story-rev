module AdminHelper
  
  # Functions for debugging and administration via the console
  def self.reset_book_accession_ids
    Book.all.each do |x|
      x.accession_id = nil
      x.save(:validate => false)
    end
    Book.order(:created_at).each do |x|
      x.save
    end
    return nil
  end
  
  def self.reset_copy_accession_ids
    Copy.all.each do |x|
      x.copy_number = nil
      x.accession_id = nil
      x.save(:validate => false)
    end
    Copy.order(:created_at).each do |x|
      x.save
    end
    return nil
  end
  
  def self.reset_and_display_accession_ids
    self.reset_book_accession_ids
    self.reset_copy_accession_ids
    self.display_copies_by_accession_id
  end
  
  def self.display_books_by_accession_id
    Book.order(:accession_id).each do |p|
      puts "#{p.accession_id} \t#{p.author.last_name}, #{p.author.first_name} - #{p.title}"
    end
    return nil
  end
  
  def self.display_copies_by_accession_id
    Copy.order(:accession_id).includes(:edition => :book).each do |c|
      p = c.edition.book
      puts "#{c.id} \t#{c.accession_id} \t#{p.author.last_name}, #{p.author.first_name} - #{p.title}"
      puts "\t\tCopy - #{c.condition_description} [#{c.price}]"
    end
    return nil
  end
  
  def self.reset(klass)
    klass.all.each do |x|
      x.save
    end
  end
  
  # Recreate cover image versions
  def self.recreate_cover_versions
    CoverImage.all.each do |c|
      c.filename.recreate_versions!
    end
  end
end
