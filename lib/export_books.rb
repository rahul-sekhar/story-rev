module ExportBooks
  def self.to_csv(copies)
    CSV.generate(headers: true) do |csv|
      csv << %w{Title Author Price New Condition Age-From Age-To Stock} 

      copies.each do |copy|
        csv << [
          copy.book.title,
          copy.book.author_name,
          copy.price,
          copy.new_copy,
          copy.condition_rating,
          copy.book.age_from,
          copy.book.age_to,
          copy.stock
        ];
      end
    end
  end
end