module DuplicateNames
  
  class Handler
    def initialize(klass, dependent_field, verbose = false)
      @klass = klass
      @dependent_field = dependent_field
      @verbose = verbose
    end

    def merge_duplicates
      checker = Checker.new(@klass)
      if @verbose
        puts "Found #{checker.invalid_objects.length} invalid #{@klass} objects:"
        checker.invalid_objects.each do |x|
          puts "\t" + x.name
        end
        puts "\n"
      end

      groups = Grouper.split(checker.invalid_objects)
      if @verbose
        puts "Split them into #{groups.length} groups, with names:"
        puts groups.map {|x| x.name }
        puts "\n"
      end

      groups.each do |g|
        puts "From group #{g.name}:"
        GroupMerger.new(g, @dependent_field, @verbose).merge
        puts "\n"
      end

      puts "Done.\n"
    end
  end


  class Checker
    attr_reader :invalid_objects

    def initialize(klass)
      @klass = klass
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
          next true
        end
      end
    end
  end


  class Group
    include Enumerable
    attr_reader :name, :objects

    def initialize(name)
      @name = name
      @objects = []
    end

    def add(object)
      @objects << object
      return self
    end

    def destroy(object)
      @objects.find{ |x| x == object }.destroy
      @objects.delete(object)
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
      # Destroy any unlinked elements
      @group.select { |x| x.send(@dependent_field).empty? }.each do |x|
        puts "\tDestroying unlinked object with name '#{x.name}'" if @verbose
        @group.destroy(x)
      end

      if @group.objects.empty?
        puts "\tNo linked objects" if @verbose
        return
      end

      # Change the name of the first goup element till it is valid
      puts "\tKeeping first object with name '#{@group.first.name}'" if @verbose
      tmp_name = @group.first.name
      while @group.first.invalid? do
        @group.first.name = @group.first.name + "x"
      end
      @group.first.save

      # Move all dependent fields to the first element of the group
      @group.objects[1..-1].each do |x|
        objects_to_shift = x.send(@dependent_field)
        puts "\tShifting #{objects_to_shift.length} objects to it" if @verbose
        p @group.first
        p objects_to_shift
        @group.first.send(@dependent_field) << objects_to_shift
        x.destroy
      end

      # Change back the name
      @group.first.name = tmp_name
      @group.first.save
    end
  end
end