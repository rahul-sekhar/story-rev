class BookFilter
  @@num_recent_books = 28

  def initialize(params)
    @params = params
    @books = Book.stocked
    @editions = Edition.scoped
    @copies = Copy.stocked
    @merge_required = false
  end

  # Apply each filter in the parameters
  def filter
    filters_available.each do |filter|
      send("filter_by_#{filter}", @params[filter]) if @params[filter].present?
    end
    filter_price
    merge
  end

  # Change the number of recent books to return, for testing purposes
  def self.num_recent_books=(val)
    @@num_recent_books = val
  end
  
  private

    def filters_available
      [:collection, :publisher, :author, :illustrator, :type, :format, :category, :age, :condition, :award, :award_winning, :recent, :search]
    end

    # Merge the books filtered with the editions and copies filtered
    def merge
      if @merge_required
        @editions = @editions.where{id.in(my{@copies}.select{edition_id})}
        @books = @books.where{id.in(my{@editions}.select{book_id})}
      end

      return @books
    end

    
    # Filters
    def filter_by_collection(val)
      @books = @books.joins{collections}.where{collections.id == val}
    end

    def filter_by_publisher(val)
      @editions = @editions.joins{book}.where{(publisher_id == val) | (book.publisher_id == val)}
      @merge_required = true
    end

    def filter_by_author(val)
      @books = @books.where(author_id: val)
    end

    def filter_by_illustrator(val)
      @books = @books.where(illustrator_id: val)
    end

    def filter_by_type(val)
      @copies = @copies.where(new_copy: (val == "new"))
      @merge_required = true
    end

    def filter_by_format(val)
      @editions = @editions.where{format_id == val}
      @merge_required = true
    end

    def filter_by_category(val)
      @books = @books.where(book_type_id: val)
    end

    def filter_by_age(val)
      @books = @books.where{ (age_from == val) | (age_to == val) | ((age_from < val) & (age_to > val)) }
    end

    def filter_by_condition(val)
      @copies = @copies.where{condition_rating >= val}
      @merge_required = true
    end

    def filter_by_award(val)
      matched_books = BookAward.joins{award}.where{award.award_type_id == val}.select{book_id}
      @books = @books.where{id.in(matched_books)}
    end

    def filter_by_award_winning(val)
      @books = @books.where{id.in(BookAward.select{book_id})}
    end

    def filter_by_recent(val)
      new_books = Book.unscoped.joins{editions.copies}
                      .select{id}.group{id}.order{max(editions.created_at).desc}
                      .where{editions.copies.stock > 0}
                      .limit(@@num_recent_books)

      @books = @books.where{id.in(new_books)}
    end

    def filter_by_search(val)
      val = "%#{SqlHelper::escapeWildcards(val)}%"
      @books = @books.joins{[illustrator.outer, author]}.where do
        title.like(val) |
        author.first_name.op('||', ' ').op('||', author.last_name).like(val) |
        illustrator.first_name.op('||', ' ').op('||', illustrator.last_name).like(val)
      end
    end

    # Price filter, checks multiple params
    def filter_price
      from = @params[:price_from]
      to = @params[:price_to]
      str_price = @params[:price]
      if str_price.present? && from.blank? && to.blank?
        
        # Regex for a price string of form: "50+"
        regex1 = /^(\d+)\+$/
        # Regex for a price string of form: "-50"
        regex2 = /^-(\d+)$/
        # Regex for a price string of form: "50-100"
        regex3 = /^(\d+)-(\d+)$/

        if str_price.match(regex1)
          from = str_price.match(regex1)[1]
        elsif str_price.match(regex2)
          to = str_price.match(regex2)[1]
        elsif str_price.match(regex3)
          from = str_price.match(regex3)[1]
          to = str_price.match(regex3)[2]
        end
      end

      if to.present?
        @copies = @copies.where{(price >= from.to_i) & (price <= to.to_i)}
        @merge_required = true
      elsif from.present?
        @copies = @copies.where{price >= from.to_i}        
        @merge_required = true
      end
    end
end