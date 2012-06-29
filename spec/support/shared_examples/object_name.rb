shared_examples_for "an object with a unique name" do
  context "when the name is nil" do
    before do 
      subject.name = nil
      subject.valid?
    end
    it { should be_invalid }
    its(:errors) { should have_key :name }
  end

  context "when the length is at the maximum length" do
    before { subject.name = "a" * max_length }
    it { should be_valid }
  end

  context "when the length is above the maximum length" do
    before do 
      subject.name = "a" * (max_length + 1)
      subject.valid?
    end
    it { should be_invalid }
    its(:errors) { should have_key :name }
  end

  context "with another object created" do
    before { create_object(name: "Object") }

    context "when its name is different" do
      before { subject.name = "Other" }
      it { should be_valid }
    end

    context "when its name is the same" do
      before { subject.name = "Object" }
      it { should be_invalid }
    end

    context "when its name is the same but with different case" do
      before { subject.name = "OBJECT" }
      it { should be_invalid }
    end
  end
end

shared_examples_for "an object findable by name" do
  context "with multiple named objects created" do
    let(:klass) { subject.class }
    before do
      ["Object", "obj", "Object 2", "Other", "Gah"].each do |name|
        create_object(name: name)
      end
    end

    describe "Retrieving a single object by name" do
      it "should retrieve an object with an existing name" do
        klass.name_is("Object").should be_a klass
      end

      it "should work case insensitively" do
        klass.name_is("OBJECT").should be_a klass
      end

      it "should return nil for a name that does not exist" do
        klass.name_is("Blah").should be_nil
      end
    end

    describe "Finding objects by name" do
      it "should return an array of objects containing the passed string" do
        klass.name_like("Object").length.should == 2
      end

      it "should work case insensitively" do
        klass.name_like("OBJ").length.should == 3
      end

      it "should return an empty array when no objects exist" do
        klass.name_like("bah").should == []
      end
    end
  end
end
