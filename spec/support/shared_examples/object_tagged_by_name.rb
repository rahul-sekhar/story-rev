shared_examples_for "object tagged by name" do
  it "should return the object name" do
    book.send("#{object}=", klass.new(name: "New #{klass}"))
    book.send("#{object}_name").should == "New #{klass}"
  end

  it "should use an object with the set name if one exists" do
    klass.should_receive(:name_is){ klass.new }.with("Existing #{klass}")
    book.send("#{object}_name=", "Existing #{klass}")
  end

  it "should create a new object if an object with the set name doesn't exist" do
    klass.stub(:name_is)
    book.send("#{object}_name=", "New #{klass}")
    book.send("#{object}").should be_new_record
    book.send("#{object}").name.should == "New #{klass}"
  end
end