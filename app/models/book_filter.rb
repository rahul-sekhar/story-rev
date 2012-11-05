class BookFilter

  def self.filter(params)
    new(params).filter
  end


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

  
  private

    def filters_available
      [:collection, :publisher, :author, :illustrator, :type, :format, :category, :age]
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