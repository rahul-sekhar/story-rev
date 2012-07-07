class BookSearcher
  attr_reader :query, :results

  def initialize(q = nil)
    self.query = q
  end

  def query=(q)
    @query = q
    @sql_query = SqlHelper::escapeWildcards(q)
    @regex_query = Regexp.escape(q)
  end

  def self.search(q)
    new(q).search
  end

  def search
    if @query.present?
      @results = do_search
    else
      # Create an empty relation if a blank query is receieved
      @results = Book.where("1 = 0")
    end

    return self
  end

  def formatted_results
    sorted_results.map do |x|
      {
        id: x.id,
        text: get_result_text(x),
      }
    end
  end

  private

  def do_search
    start_matcher = "#{@sql_query}%"
    word_boundary_matchers = ["#{@sql_query}%", "% #{@sql_query}%"]

    Book.joins(:author).where do
      title.like_any(word_boundary_matchers) | 
      
      authors.first_name.op('||', ' ').op('||', authors.last_name).
      like_any(word_boundary_matchers) |

      cast(accession_id.as 'varchar(8)').like(start_matcher)
    end
  end

  # Returns the result text depending on which attribute was matched
  def get_result_text(book)
    if book.accession_id.to_s =~ partial_match_regex
      "#{book.accession_id} - #{book.title}"
    elsif book.author_name =~ partial_match_regex
      "#{book.author_name} - #{book.title}"
    else
      book.title
    end
  end

  def sorted_results
    return [] if @results.nil?

    @results.sort_by do |x|
      if exact_match(x)
        1
      elsif word_match(x)
        2
      else
        3
      end
    end
  end

  def exact_match(book)
    book.title.casecmp(@query) == 0 || 
    book.author_name.casecmp(@query) == 0 ||
    book.accession_id.to_s.casecmp(@query) == 0
  end

  def word_match(book)
    book.title =~ word_match_regex ||
    book.author_name =~ word_match_regex
  end

  def partial_match_regex
    # Use an unmatchable regex if a blank query is given
    @query.present? ? /\b#{@regex_query}/i : /\b\B/
  end

  def word_match_regex
    # Use an unmatchable regex if a blank query is given
    @query.present? ? /\b#{@regex_query}\b/i : /\b\B/
  end
end