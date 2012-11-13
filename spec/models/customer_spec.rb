require 'spec_helper'

describe Customer do
  let(:customer) { build(:customer) }
  
  it "initially sets the step to 1 if the order is not final" do
    customer.step.should == 1
  end

  it "initially sets the step to 1 if the order is final" do
    o = create(:complete_order)
    c = create(:customer, complete_order: o)
    c = Customer.find(c.id)
    c.step.should == 4
  end

  describe "#step" do
    context "when there is no last valid step" do
      before do
        customer.delivery_method = nil
        customer.payment_method_id = 1
      end

      it "sets the step to 1 given any step" do
        [0,1,2,3,4,"a"].each do |x|
          customer.step = x
          customer.step.should == 1
        end
      end

      it "does not set any errors" do
        customer.step = 3
        customer.errors.should be_empty
      end
    end

    context "when the first step is valid" do
      before do
        customer.name = "blah"
        customer.email = "a@b.c"
      end

      it "sets the step to 2 given any step except 1" do
        [0,2,3,4,"a"].each do |x|
          customer.step = x
          customer.step.should == 2
        end
      end

      it "sets the step to 1 for step 1" do
        customer.step = 1
        customer.step.should == 1
      end
    end

    context "when the first two steps are valid" do
      before do
        customer.payment_method_id = 2
      end

      it "sets the step to 3 given any step except 1 and 2" do
        [0,3,4,"a"].each do |x|
          customer.step = x
          customer.step.should == 3
        end
      end

      it "sets the correct step for steps 1 and 2" do
        [1,2].each do |x|
          customer.step = x
          customer.step.should == x
        end
      end
    end

    context "when all steps are valid" do
      before do
        customer.payment_method_id = 3
        customer.name = "blah"
        customer.email = "a@b.c"
      end

      it "sets the step to 4 given any step except 1, 2 and 3" do
        [0,4,"a"].each do |x|
          customer.step = x
          customer.step.should == 4
        end
      end

      it "sets the correct step for steps 1, 2 and 3" do
        [1,2,3].each do |x|
          customer.step = x
          customer.step.should == x
        end
      end
    end
  end

  describe "delivery_method" do
    it "is nil initially" do
      Customer.new.delivery_method.should be_nil
    end

    it "is invalid when nil" do
      customer.delivery_method = nil
      customer.should be_invalid
      customer.errors.should have_key :delivery_method
    end

    it "is valid when set to 1" do
      [1, "1"].each do |x|
        customer.delivery_method = x
        customer.should be_valid
      end
    end

    context "delivery method set to '2'" do
      before do
        customer.delivery_method = 2
      end

      it "is invalid without a pickup point" do
        customer.should be_invalid
      end

      it "is valid with a pickup point" do
        customer.pickup_point = create(:pickup_point)
        customer.should be_valid
      end

      it "is valid with a pickup point id of 0" do
        customer.pickup_point_id = "0"
        customer.should be_valid
      end

      it "is invalid with a non existant pickup point" do
        customer.pickup_point_id = 1
        customer.should be_invalid
      end

      it "stores pickup_point_id" do
        pp = create(:pickup_point)
        customer.pickup_point = pp
        customer.save
        customer.reload
        customer.pickup_point_id.should == pp.id
      end

      it "clears other_pickup if pickup_point_id is not 0" do
        customer.pickup_point = create(:pickup_point)
        customer.other_pickup = "blah"
        customer.save
        customer.reload
        customer.other_pickup.should be_nil
      end

      it "stores other_pickup if pickup_point_id is 0" do
        customer.pickup_point_id = 0
        customer.other_pickup = "blah"
        customer.save
        customer.reload
        customer.pickup_point_id.should == 0
        customer.other_pickup.should == "blah"
      end
    end

    it "is invalid when set to anything but 1 or 2" do
      [3, 0, "0", "a"].each do |x|
        customer.delivery_method = x
        customer.should be_invalid
      end
    end

    it "clears other_pickup and pickup_point_id" do
      customer.pickup_point_id = 0
      customer.other_pickup = "blah"
      customer.save
      customer.reload
      customer.pickup_point_id.should be_nil
      customer.other_pickup.should be_nil
    end
  end

  describe "payment_method" do
    it "is valid if the step is below 2" do
      [1,0,4,nil].each do |x|
        customer.payment_method_id = x
        customer.should be_valid
      end
    end

    context "when the step is 2" do
      before{ customer.step = 2 }

      it "is valid if in [1,2,3]" do
        [1,2,3,"1"].each do |x|
          customer.payment_method_id = x
          customer.should be_valid
        end
      end

      it "is invalid if not in [1,2,3]" do
        [0,4,"a"].each do |x|
          customer.payment_method_id = x
          customer.should be_invalid
        end
      end
    end
  end

  describe "name" do
    before do
      customer.payment_method_id = 1
      customer.email = "valid@email.com"
    end

    it "is valid if the step is below 3" do
      customer.name = nil
      customer.payment_method_id = 1
      [1,2].each do |x|
        customer.step = x
        customer.should be_valid
      end
    end

    context "when the step is 3" do
      before{ customer.step = 3 }

      it "is invalid when nil" do
        customer.name = nil
        customer.should be_invalid
      end

      it "is invalid when blank" do
        customer.name = ""
        customer.should be_invalid
      end

      it "is valid when at most 150 chars" do
        customer.name = "a" * 150
        customer.should be_valid
      end

      it "is invalid when more than 150 chars" do
        customer.name = "a" * 151
        customer.should be_invalid
      end
    end
  end

  describe "email" do
    before do
      customer.payment_method_id = 1
      customer.name = "valid name"
    end

    it "is valid if the step is below 3" do
      customer.email = nil
      
      [1,2].each do |x|
        customer.step = x
        customer.should be_valid
      end
    end

    context "when the step is 3" do
      before{ customer.step = 3 }

      it "is invalid when nil" do
        customer.email = nil
        customer.should be_invalid
      end

      it "is invalid when blank" do
        customer.email = ""
        customer.should be_invalid
      end

      it "is invalid when not the right format" do
        ["a@a", "blah", "b.com"].each do |x|
          customer.email = x
          customer.should be_invalid
        end
      end

      it "is valid when the right format" do
        ["a@a.b", "blah.bl@hm.in", "rahul@gmail.com" "a.b@c.i.d"].each do |x|
          customer.email = x
          customer.should be_valid
        end
      end

      it "is valid when at most 100 chars" do
        customer.email = "a" * 90 + "@bleah.com"
        customer.should be_valid
      end

      it "is invalid when more than 150 chars" do
        customer.email = "a" * 91 + "@bleah.com"
        customer.should be_invalid
      end
    end
  end

  describe "#set_defaults" do
    context "when step is 1" do
      it "does not set payment_method_id" do
        customer.set_defaults
        customer.payment_method_id.should be_nil
      end

      it "does not change delivery_method if already set" do
        customer.delivery_method = 2
        customer.set_defaults
        customer.delivery_method.should == 2
      end

      it "sets delivery_method to 1 if nil" do
        customer.delivery_method = nil
        customer.set_defaults
        customer.delivery_method.should == 1
      end
    end

    context "when step is 2" do
      before{ customer.step = 2 }

      it "does not change payment_method_id if already set" do
        customer.payment_method_id = 3
        customer.set_defaults
        customer.payment_method_id.should == 3
      end

      it "sets payment_method_id to 1 if nil" do
        customer.payment_method_id = nil
        customer.set_defaults
        customer.payment_method_id.should == 1
      end
    end
  end
end