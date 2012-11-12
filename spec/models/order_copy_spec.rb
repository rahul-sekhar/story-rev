require 'spec_helper'

describe OrderCopy, :focus do
  let(:order_copy){ build(:order_copy) }

  it "is valid" do
    order_copy.should be_valid
  end

  it "is invalid without a copy" do
    order_copy.copy = nil
    order_copy.should be_invalid
  end

  describe "#ticked" do
    it "is invalid when blank or nil" do
      [nil, ""].each do |x|
        order_copy.ticked = x
        order_copy.should be_invalid, x
      end
    end

    it "is valid when either true or false" do
      [true, false].each do |x|
        order_copy.ticked = x
        order_copy.should be_valid, x
      end
    end
  end

  describe "#number" do
    it "is 1 by default" do
      order_copy.number.should == 1
    end

    context "with a used copy" do
      before do
        order_copy.copy = create(:used_copy_with_book)
      end

      it "does not allow the number to be written" do
        [nil, 0, 1, 2, -1].each do |x|
          order_copy.number = x
          order_copy.number.should == 1
        end
      end
    end

    describe "price" do
      it "is the copy price for a single copy" do
        order_copy.copy = create(:used_copy_with_book, price: 65)
        order_copy.price.should == 65
      end

      it "is the copy price multipled by the number for multiple copies" do
        order_copy.copy = create(:new_copy_with_book, price: 60)
        order_copy.number = 4
        order_copy.price.should == 240
      end
    end

    context "with a new copy" do
      before do
        order_copy.copy = create(:new_copy_with_book)
      end

      it "allows the number to be written for a positive integer" do
        [1, 1000].each do |x|
          order_copy.number = x
          order_copy.number.should == x
        end
      end

      it "does not allow the number to be written if negative" do
        [0, -2, -1].each do |x|
          order_copy.number = x
          order_copy.number.should == 1
        end
      end
    end
  end

  describe "scope #stocked" do
    it "returns stocked order copies" do
      o = create(:order)
      oc1 = create(:order_copy, order: o, copy: create(:used_copy_with_book))
      oc2 = create(:order_copy, order: o, copy: create(:used_copy_with_book, stock: 0))
      oc3 = create(:order_copy, order: o, copy: create(:new_copy_with_book))
      oc4 = create(:order_copy, order: o, copy: create(:new_copy_with_book, stock: 1))

      OrderCopy.stocked.should =~ [oc1, oc4]
    end
  end

  describe "scope #unstocked" do
    it "returns unstocked order copies" do
      o = create(:order)
      oc1 = create(:order_copy, order: o, copy: create(:used_copy_with_book))
      oc2 = create(:order_copy, order: o, copy: create(:used_copy_with_book, stock: 0))
      oc3 = create(:order_copy, order: o, copy: create(:new_copy_with_book))
      oc4 = create(:order_copy, order: o, copy: create(:new_copy_with_book, stock: 1))

      OrderCopy.unstocked.should =~ [oc2, oc3]
    end
  end
end