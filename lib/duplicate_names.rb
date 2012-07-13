module DuplicateNames
  
  class Handler
    def initialize(klass, dependent_field)
      @klass = klass
      @dependent_field = dependent_field
    end

    def merge_duplicates
      checker = Checker.new(@klass, true)
      groups = Grouper.split(checker.invalid_objects)
      groups.each do |g|
        GroupMerger.new(g, dependent_field, true).merge
      end
    end
  end


  class Checker
    attr_reader :invalid_objects

    def initialize(klass, verbose = false)
      @klass = klass
      @verbose = verbose
      check
    end

    def invalid?
      @invalid_objects.length > 0
    end

    def valid?
      !invalid?
    end

    private

    def check
      @invalid_objects = @klass.all.select do |x| 
        if x.invalid?
          if x.errors.keys != [:name]
            raise Exception.new("Object has an invalid attribute apart from its name - #{x.inspect}")
          end
          puts "Invalid #{@klass.to_s} - '#{x.name}'" if @verbose
          next true
        end
      end
    end
  end


  class Group
    include Enumerable
    attr_reader :name

    def initialize(name)
      @name = name
      @objects = []
    end

    def add(object)
      @objects << object
      return self
    end

    def matches(string)
      string.strip.downcase == name.strip.downcase
    end

    def each
      @objects.each { |x| yield x }
    end
  end


  class Grouper
    def initialize()
      @groups = []
    end

    def split(objects)
      objects.each { |x| find_or_create_group(x.name).add(x) }
      return @groups
    end

    def self.split(objects)
      new.split(objects)
    end

    def find_or_create_group(name)
      group = @groups.find{ |g| g.matches(name) }
      unless group
        group = Group.new(name)
        @groups << group
      end
      return group
    end
  end


  class GroupMerger
    def initialize(group, dependent_field, verbose = false)
      raise Exception.new("Excepted type Group") unless group.is_a? Group
      @group = group
      @dependent_field = dependent_field
      @verbose = verbose
    end

    def merge
      destroy_unlinked_objects
      
    end

    private

    def destroy_unlinked_objects

    end
  end
end