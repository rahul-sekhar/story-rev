require 'spec_helper'

describe CustomerPresenter, type: :decorator do
  let(:customer) { Customer.new }
  subject {CustomerPresenter.new(customer, view)}

  describe "#delivery_text" do
    it "is 'courier' when delivery_method is 1" do
      customer.delivery_method = 1
      subject.delivery_text.should == "Delivery by courier"
    end

    it "is 'pickup' when delivery_method is 2" do
      customer.delivery_method = 2
      subject.delivery_text.should == "Delivery by pickup"
    end

    it "is nil otherwise" do
      customer.delivery_method = 3
      subject.delivery_text.should == nil
    end
  end

  describe "#delivery_short" do
    it "is 'Post' when delivery_method is 1" do
      customer.delivery_method = 1
      subject.delivery_short.should == "Post"
    end

    it "is 'Pick-up' when delivery_method is 2" do
      customer.delivery_method = 2
      subject.delivery_short.should == "Pick-up"
    end

    it "is nil otherwise" do
      customer.delivery_method = 3
      subject.delivery_short.should == nil
    end
  end

  describe "#payment_text" do
    it "is the lower case name of the payment method" do
      customer.stub_chain("payment_method.name").and_return("Some Name")
      subject.payment_text.should == "Payment by some name"
    end
  end

  describe "#pickup_point_text" do
    it "is blank if the delivery method is not 2" do
      customer.delivery_method = 1
      subject.pickup_point_text.should == ""
    end

    it "is the short pickup point text with a heading otherwise" do
      customer.delivery_method = 2
      subject.stub(:pickup_point_short_text).and_return("some text")
      subject.pickup_point_text.should == "Pickup point: some text"
    end
  end

  describe "#short_pickup_point_text" do
    it "is the pickup point name if present" do
      customer.stub(:pickup_point).and_return(true)
      customer.stub_chain("pickup_point.name").and_return("Point")
      subject.pickup_point_short_text.should == "Point"
    end

    it "is the other pickup text if the pickup point is not present" do
      customer.stub(:pickup_point).and_return(false)
      customer.stub(:other_pickup).and_return("Some other point")
      subject.pickup_point_short_text.should == "Some other point (other)"
    end
  end

  describe "#full_address" do
    specify "just address" do
      customer.address = "some\naddress"
      subject.full_address.should == "some\naddress"
    end

    specify "just city" do
      customer.city = "Bangalore"
      subject.full_address.should == "Bangalore"
    end

    specify "just pin code" do
      customer.pin_code = "567-234"
      subject.full_address.should == "567-234"
    end

    specify "city and pin code" do
      customer.city = "City"
      customer.pin_code = "123456"
      subject.full_address.should == "City - 123456"
    end

    specify "address and city" do
      customer.address = "some\naddress"
      customer.city = "City"
      subject.full_address.should == "some\naddress\nCity"
    end

    specify "address and pin code" do
      customer.address = "some\naddress"
      customer.pin_code = "56"
      subject.full_address.should == "some\naddress\n56"
    end

    specify "address, city and pin code" do
      customer.address = "some\naddress"
      customer.city = "City"
      customer.pin_code = "560042"
      subject.full_address.should == "some\naddress\nCity - 560042"
    end
  end

  it "delegates #name to the object" do
    customer.should_receive(:name).and_return(:ret)
    subject.name.should == :ret
  end

  it "delegates #phone to the object" do
    customer.should_receive(:phone).and_return(:ret)
    subject.phone.should == :ret
  end

  it "delegates #email to the object" do
    customer.should_receive(:email).and_return(:ret)
    subject.email.should == :ret
  end

  it "delegates #other_info to the object" do
    customer.should_receive(:other_info).and_return(:ret)
    subject.other_info.should == :ret
  end
end