require 'spec_helper'
require 'duplicate_names'

module DuplicateNames
  class TestClass
    def self.set(objects)
      @objects = objects
    end
    
    def self.all
      @objects
    end
  end

  class ValidObj
    attr_accessor :name

    def initialize(name = nil)
      @name = name
    end

    def invalid?
      false
    end

    def valid?
      true
    end

    def errors
      {}
    end
  end

  class InvalidObj
    attr_accessor :name

    def initialize(name = nil)
      @name = name
    end

    def invalid?
      true
    end

    def valid?
      false
    end

    def errors
      { name: "must be unique" }
    end
  end

  describe DuplicateNames, :duplicate_names do
    describe Handler do
      describe '#merge_duplicates' do
        
      end
    end

    describe Checker do
      subject(:checker) { Checker.new(TestClass) }
      it "should be valid when the class contains invalid objects" do
        TestClass.set([ValidObj.new, InvalidObj.new])
        checker.should be_invalid
      end

      it "should be valid when the class contains no invalid objects" do
        TestClass.set([ValidObj.new, ValidObj.new])
        checker.should be_valid
      end

      it "should be valid when the class contains no objects" do
        TestClass.set([])
        checker.should be_valid
      end

      it "should return the invalid objects of the class when a single object is invalid" do
        invalid_obj = InvalidObj.new
        TestClass.set([ValidObj.new, invalid_obj])
        checker.invalid_objects.count.should == 1
        checker.invalid_objects.first.should equal(invalid_obj)
      end

      it "should return all the invalid objects of the class when multiple objects are invalid" do
        invalid_obj1 = InvalidObj.new
        invalid_obj2 = InvalidObj.new
        TestClass.set([invalid_obj1, ValidObj.new, invalid_obj2, ValidObj.new])
        checker.invalid_objects.count.should == 2
        checker.invalid_objects.should include(invalid_obj1)
        checker.invalid_objects.should include(invalid_obj2)
      end

      it "should be empty when only valid objects are present" do
        TestClass.set([ValidObj.new, ValidObj.new])
        checker.invalid_objects.count.should == 0
      end

      it "should raise an exception when any field other than the name is invalid" do
        invalid_obj = InvalidObj.new
        invalid_obj.stub(:errors).and_return({ name: "Blah", other: "Blah" })
        TestClass.set([invalid_obj])
        expect { checker.invalid? }.to raise_exception
      end
    end

    describe Grouper do
      describe '#split' do
        context "when passed a single object" do
          before do
            @obj = InvalidObj.new("A thing")
            @groups = Grouper.split([@obj])
          end

          it "should return an array containing a single group" do
            @groups.should be_a Array
            @groups.length.should == 1
            @groups.first.should be_a Group
          end

          specify "the group should be named after the object" do
            @groups.first.name.should == @obj.name
          end

          specify "the group should contain the object" do
            group = @groups.first
            group.count.should == 1
            group.first.should equal(@obj)
          end
        end

        context "when passed multiple differently named objects" do
          before do
            @obj1 = InvalidObj.new("Some Thing")
            @obj2 = InvalidObj.new("Other Thing")
            @groups = Grouper.split([@obj1, @obj2])
          end

          it "should return an array containing two groups" do
            @groups.should be_a Array
            @groups.length.should == 2
            @groups.each { |x| x.should be_a Group }
          end

          specify "each group should be named after its object" do
            @groups.find{ |x| x.name == "Some Thing" }.should be_present
            @groups.find{ |x| x.name == "Other Thing" }.should be_present
          end

          specify "each group should contain its object" do
            group1 = @groups.find{ |x| x.name == "Some Thing" }
            group1.count.should == 1
            group1.first.should equal(@obj1)
            group2 = @groups.find{ |x| x.name == "Other Thing" }
            group2.count.should == 1
            group2.first.should equal(@obj2)
          end
        end

        context "when passed two objects with the same name but different cases" do
          before do
            @obj1 = InvalidObj.new("Some Thing")
            @obj2 = InvalidObj.new("some thing")
            @groups = Grouper.split([@obj1, @obj2])
          end

          it "should return an array containing one group" do
            @groups.should be_a Array
            @groups.length.should == 1
            @groups.first.should be_a Group            
          end

          specify "the group name should be either of the object names" do
            @groups.first.name.should satisfy do |x| 
              x == "Some Thing" || x == "some thing"
            end
          end

          specify "the group should contain both objects" do
            @groups.first.should include(@obj1)
            @groups.first.should include(@obj2)
          end
        end

        context "when passed two objects with the same name but with leading and trailing whitespace" do
          before do
            @obj1 = InvalidObj.new("Some Thing")
            @obj2 = InvalidObj.new(" Some thing  ")
            @groups = Grouper.split([@obj1, @obj2])
          end

          it "should return an array containing one group" do
            @groups.should be_a Array
            @groups.length.should == 1
            @groups.first.should be_a Group            
          end

          specify "the group name should be either of the object names" do
            @groups.first.name.should satisfy do |x| 
              x == "Some Thing" || x == "some thing"
            end
          end

          specify "the group should contain both objects" do
            @groups.first.should include(@obj1)
            @groups.first.should include(@obj2)
          end
        end

        context "when passed many objects" do
          before do
            @groups = Grouper.split([
              InvalidObj.new("Something"),
              InvalidObj.new("Something "),
              InvalidObj.new("Bleh"),
              InvalidObj.new("Bahahah ahah"),
              InvalidObj.new(" bahahah ahah")
            ])
          end

          it "should return the correct number of groups" do
            @groups.length.should == 3
          end
        end
      end
    end

    describe GroupMerger do
      
      it "should raise an exception when passed a group not of the Group type" do
        expect{ GroupMerger.new(["asdf"], :attr) }.to raise_exception
      end

      describe '#merge' do
        let(:group) { Group.new("Some Group") }
        subject(:merger) { GroupMerger.new(group, :dependents) }

        it "should remove any objects unlinked to dependents" do
          unlinked_obj = InvalidObj.new("Something")
          unlinked_obj.stub(:dependents).
          group.add(ww)
        end
      end
    end
  end
end