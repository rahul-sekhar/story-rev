shared_examples_for "a person" do
  let (:klass) { subject.class }
  it "should correctly return the full name with both a first name and last name set" do
    person.first_name = "First"
    person.last_name = "Second"
    person.name.should == "First Second"
  end

  it "should correctly return the full name with only the last name set" do
    person.first_name = nil
    person.last_name = "Second"
    person.name.should == "Second"
  end

  describe "splitting the full name" do
    it "should split a two word name" do
      person.name = "First Second"
      person.first_name.should == "First"
      person.last_name.should == "Second"
    end

    it "should split a multiple word name" do
      person.name = "First Second Third Fourth"
      person.first_name.should == "First Second Third"
      person.last_name.should == "Fourth"
    end

    it "should split a name with a uncapitalized word before the last name" do
      person.name = "First second Third"
      person.first_name.should == "First"
      person.last_name.should == "second Third"
    end

    it "should split a name with a uncapitalized word before the last name and multiple words before that" do
      person.name = "First second Third fourth Fifth"
      person.first_name.should == "First second Third"
      person.last_name.should == "fourth Fifth"
    end

    it "should split a single word name" do
      person.name = "First"
      person.first_name.should be_blank
      person.last_name.should == "First"
    end

    it "should split a two word name with one uncapitalized word" do
      person.name = "first Second"
      person.first_name.should be_blank
      person.last_name.should == "first Second"
    end

    it "should split a name with uncapitalized words" do
      person.name = "first second"
      person.first_name.should be_blank
      person.last_name.should == "first second"

      person.name = "first"
      person.first_name.should be_blank
      person.last_name.should == "first"
    end

    it "should split a name with multiple uncapitalized words before the last name" do
      person.name = "First second Third fourth fifth Sixth"
      person.first_name.should == "First second Third"
      person.last_name.should == "fourth fifth Sixth"
    end

    it "should split a name correctly with multiple spaces in the name" do
      person.name = "First  second  Third     fourth  Fifth"
      person.first_name.should == "First second Third"
      person.last_name.should == "fourth Fifth"
    end
  end

  context "when multiple people have been created" do
    before do
      ["Rahul Sekhar", "Rahul de Sekhar", "Rahul", "Sekhar", "Other Person", "Some Other Person", "Alan Carson"].each do |name|
        create_person(name: name)
      end
    end

    describe "Retrieving a person by name" do
      it "should work for a full name" do
        klass.name_is("Rahul Sekhar").should be_a klass
      end

      it "should work for a full name with an uncapitalized middle name" do
        klass.name_is("Rahul de Sekhar").should be_a klass
      end

      it "should work for a three worded name" do
        klass.name_is("Some Other Person").should be_a klass
      end

      it "should work for a single word name" do
        klass.name_is("Rahul").should be_a klass
      end

      it "should return nil for a non-existant name" do
        klass.name_is("Rahul Dekhar").should be_nil
      end

      it "should return nil for a part of an existing name" do
        klass.name_is("Person").should be_nil
        klass.name_is("Other").should be_nil
      end

      it "should be case insensitive" do
        klass.name_is("rahul sekhar").should be_a klass
      end

      it "should escape SQL wildcards" do
        klass.name_is("Rahu%").should be_nil
        create_person(name: "Rahu%")
        klass.name_is("Rahu%").should be_a klass
      end
    end

    describe "Finding people by name" do
      it "should retrieve people by their full name" do
        klass.name_like("Rahul Sekhar").length.should == 1
      end

      it "should retrieve people by a part of their name" do
        klass.name_like("Rahul").length.should == 3
        klass.name_like("son").length.should == 3
      end

      it "should be case insensitive" do
        klass.name_like("RAHUL").length.should == 3
      end

      it "should return an empty array when the name does not exist" do
        klass.name_like("shal").length.should == 0
      end

      it "should escape SQL wildcards" do
        klass.name_like("rah%").length.should == 0
        klass.name_like("rah*").length.should == 0
        create_person(name: "rah%ul sekhar")
        klass.name_like("rah%").length.should == 1
      end
    end
  end
end