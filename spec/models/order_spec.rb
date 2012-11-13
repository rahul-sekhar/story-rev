require 'spec_helper'

describe Order do
  let(:built_order) { build(:order) }
  let(:order) { create(:order) }
  subject { order }

  it { should be_valid }

  it "only returns orders with complete set to false" do
    o1 = create(:order)
    o2 = create(:order, complete: true)
    Order.all.should == [o1]
  end

  describe "#total_amount" do
    it "defaults to 0" do
      built_order.total_amount.should == 0
    end

    it "cannot be nil" do
      built_order.total_amount = nil
      built_order.should be_invalid
    end

    it "cannot be negative" do
      built_order.total_amount = -1
      built_order.should be_invalid
    end

    it "can be zero" do
      built_order.total_amount = 0
      built_order.should be_valid
    end
    
    it "can be a positive integer" do
      built_order.total_amount = 40
      built_order.should be_valid
    end
  end

  describe "#postage_amount" do
    it "defaults to 0" do
      built_order.postage_amount.should == 0
    end

    it "cannot be nil" do
      built_order.postage_amount = nil
      built_order.should be_invalid
    end

    it "cannot be negative" do
      built_order.postage_amount = -1
      built_order.should be_invalid
    end

    it "can be zero" do
      built_order.postage_amount = 0
      built_order.should be_valid
    end
    
    it "can be a positive integer" do
      built_order.postage_amount = 40
      built_order.should be_valid
    end
  end

  describe "#complete" do
    it "defaults to false" do
      built_order.complete.should == false
    end

    it "is invalid when blank or nil" do
      [nil, ""].each do |x|
        built_order.complete = x
        built_order.should be_invalid
      end
    end

    it "is valid when either true or false" do
      [true, false].each do |x|
        built_order.complete = x
        built_order.should be_valid
      end
    end
  end

  describe "#number_of_items" do
    it "is 0 for a new order" do
      Order.new.number_of_items.should == 0
    end

    it "is equal to the total number of copies" do
      create(:order_copy, order: order, copy: create(:used_copy_with_book), number: 3)
      create(:order_copy, order: order, copy: create(:new_copy_with_book, stock: 4))
      create(:order_copy, order: order, copy: create(:new_copy_with_book))
      create(:order_copy, order: order, copy: create(:used_copy_with_book, stock: 0))
      order.number_of_items.should == 4
    end
  end

  describe "#add_copy" do
    it "does not work unless the order is saved" do
      c = create(:used_copy_with_book)
      expect{ Order.new.add_copy = c.id }.to raise_exception(ActiveRecord::RecordNotSaved)
    end

    it "adds a copy to the order" do
      c = create(:used_copy_with_book)
      order.add_copy = c.id
      order.used_copies.should == [c]
    end

    it "adds a order_copy with 1 copy" do
      c = create(:new_copy_with_book)
      order.add_copy = c.id
      oc = order.order_copies.first
      oc.new_copy.should == c
      oc.number.should == 1
    end

    it "is invalid if a non-existing copy is added" do
      order.add_copy = 1
      order.should be_invalid
    end

    it "does not add a used copy if already present" do
      c = create(:used_copy_with_book)
      order.add_copy = c.id
      order.add_copy = c.id
      order.used_copies.should == [c]
      order.order_copies.length.should == 1
    end

    it "does not add a new copy if already present" do
      c = create(:new_copy_with_book)
      order.add_copy = c.id
      order.add_copy = c.id
      order.new_copies.should == [c]
      order.order_copies.length.should == 1
    end
  end

  describe "#remove_copy" do
    it "removes a copy from the order, given its id" do
      c = create(:used_copy_with_book)
      create(:order_copy, order: order, copy: c)
      order.remove_copy = c.id
      order.used_copies.should be_empty
    end

    it "does nothing if the copy is not present" do
      c = create(:used_copy_with_book)
      create(:order_copy, order: order, copy: c)
      order.remove_copy = c.id + 1
      order.used_copies.should == [c]
    end

    it "destroys the order copy" do
      c = create(:used_copy_with_book)
      oc = create(:order_copy, order: order, copy: c)
      order.remove_copy = c.id
      order.order_copies.length.should == 0
      OrderCopy.find_by_id(oc.id).should be_nil
    end

    it "does not destroy the copy" do
      c = create(:used_copy_with_book)
      oc = create(:order_copy, order: order, copy: c)
      order.remove_copy = c.id
      Copy.find_by_id(c.id).should be_present
    end
  end

  describe "#empty" do
    it "removes all copies present in the order" do
      create(:order_copy, order: order, copy: create(:used_copy_with_book), number: 3)
      create(:order_copy, order: order, copy: create(:new_copy_with_book, stock: 4))
      order.empty = true
      order.copies.should be_empty
    end

    it "destroys all of the orders order copies" do
      create(:order_copy, order: order, copy: create(:used_copy_with_book), number: 3)
      create(:order_copy, order: order, copy: create(:new_copy_with_book, stock: 4))
      expect{ order.empty = true }.to change{OrderCopy.count}.by(-2)
    end

    it "does nothing if the order is empty" do
      order.empty = true
      order.copies.should be_empty
    end
  end

  describe "#change_number" do
    before do
      @c1 = create(:new_copy_with_book, stock: 5)
      @c2 = create(:new_copy_with_book, stock: 4)
      @oc1 = create(:order_copy, order: order, copy: @c1, number: 3)
      @oc2 = create(:order_copy, order: order, copy: @c2)
    end

    it "finds the order copy with the copy to change and changes its number" do
      order.change_number = { 'copy_id' => @c2.id, 'number' => 5 }
      @oc1.reload.number.should == 3
      @oc2.reload.number.should == 5
    end

    it "does not change used copies" do
      c = create(:used_copy_with_book)
      oc = create(:order_copy, order: order, copy: c)
      order.change_number = { 'copy_id' => c.id, 'number' => 2 }
      oc.reload.number.should == 1
    end

    it "does not change the number to 0" do
      order.change_number = { 'copy_id' => @c1.id, 'number' => 0 }
      @oc1.reload.number.should == 3
    end

    it "raises an error for an invalid id" do
      c = create(:new_copy_with_book)
      expect do
        order.change_number = { 'copy_id' => c.id, 'number' => 3}
      end.to raise_error
    end
  end

  context "when deleted" do
    it "destroys its customer if present" do
      create(:customer, order: order)
      expect{ order.destroy }.to change{Customer.count}.by(-1)
    end

    it "destroys any order copies present" do
      create(:order_copy, order: order, copy: create(:used_copy_with_book))
      create(:order_copy, order: order, copy: create(:new_copy_with_book))
      expect{ order.destroy }.to change{OrderCopy.count}.by(-2)
    end

    it "does not destroy copies" do
      create(:order_copy, order: order, copy: create(:used_copy_with_book))
      create(:order_copy, order: order, copy: create(:new_copy_with_book))
      expect{ order.destroy }.to change{Copy.count}.by(0)
    end
  end

  describe "#calculate_amount" do
    before do
      order.customer = create(:customer)
      create(:order_copy, copy: create(:used_copy_with_book, price: 50), order: order, final: true)
      create(:order_copy, copy: create(:used_copy_with_book, price: 100), order: order, final: false)
      create(:order_copy, copy: create(:new_copy_with_book, stock: 5, price: 120), order: order, number: 3, final: true)
      create(:order_copy, copy: create(:used_copy_with_book, price: 90, stock: 0), order: order, final: true)
      create(:order_copy, copy: create(:new_copy_with_book, price: 80), order: order, number: 1, final: false)
    end

    describe "amount calculation without postage" do
      before{ order.customer.delivery_method = 2 }

      it "totals the price of finalized order copies ignoring stock" do
        order.calculate_amounts
        order.postage_amount.should == 0
        order.total_amount.should == 500
      end
    end

    describe "amount calculation with postage" do
      before{ order.customer.delivery_method = 1 }

      it "totals the price of the order copies including postage" do
        order.calculate_amounts
        order.postage_amount.should == 60
        order.total_amount.should == 560
      end
    end

    describe "amount calculation without a customer" do
      before do
        order.customer.destroy
        order.reload
      end

      it "raises an exception" do
        expect { order.calculate_amounts }.to raise_exception
      end
    end
  end

  describe "#cart_amount" do
    it "calculates the total of all copies in the order" do
      create(:order_copy, copy: create(:used_copy_with_book, price: 50), order: order)
      create(:order_copy, copy: create(:used_copy_with_book, price: 100, stock: 0), order: order)
      create(:order_copy, copy: create(:new_copy_with_book, price: 120), order: order, number: 3)
      order.cart_amount.should == 510
    end
  end

  describe "#clear_old" do
    it "clears incomplete orders that are more than two weeks old" do
      o1 = Order.new
      o1.updated_at = 14.days.ago - 1.minute
      o1.save
      o2 = Order.new
      o2.updated_at = 14.days.ago + 1.minute
      o2.save

      Order.clear_old(true)

      Order.find_by_id(o1.id).should be_nil
      Order.find_by_id(o2.id).should == o2
    end

    it "does not clear complete orders" do
      o1 = CompleteOrder.new
      o1.updated_at = 14.days.ago - 1.minute
      o1.save
      o2 = CompleteOrder.new
      o2.updated_at = 14.days.ago + 1.minute
      o2.save

      Order.clear_old(true)

      CompleteOrder.find_by_id(o1.id).should == o1
      CompleteOrder.find_by_id(o2.id).should == o2
    end
  end

  describe "#check_unstocked" do
    before{ order.customer = create(:customer, delivery_method: 1) }
    
    it "sets final to false for any unstocked order copies" do
      oc1 = create(:order_copy, copy: create(:used_copy_with_book, price: 100, stock: 0), order: order, final: true)
      oc2 = create(:order_copy, copy: create(:new_copy_with_book, price: 120), order: order, number: 3)
      order.check_unstocked
      oc1.reload.final.should == false
      oc2.reload.final.should == false
    end

    it "sets final to true for any stocked order copies" do
      oc1 = create(:order_copy, copy: create(:used_copy_with_book, price: 100), order: order)
      oc2 = create(:order_copy, copy: create(:new_copy_with_book, price: 120, stock: 1), order: order)
      order.check_unstocked
      oc1.reload.final.should == true
      oc2.reload.final.should == true
    end
  end

  describe "#finalize" do
    before do
      create(:customer, 
        order: order,
        delivery_method: 1,
        payment_method_id: 1,
        name: "Test",
        email: "valid@email.com"
      )
    end

    it "raises an error if the customer is not present" do
      order.customer = nil
      expect{ order.finalize }.to raise_error
    end

    it "raises an error if the customer is not valid" do
      order.customer.email = nil
      expect{ order.finalize }.to raise_error
    end

    it "raises an error if the order is already final" do
      order.complete = true
      expect{ order.finalize }.to raise_error
    end

    it "removes any previously unfinalized copies" do
      oc1 = create(:order_copy, order: order)
      oc2 = create(:order_copy, order: order, final: true)
      expect{ order.finalize }.to change{OrderCopy.count}.by(-1)
      order.order_copies.should == [oc2]
    end

    it "sets any unstocked copies to unfinalized" do
      oc1 = create(:order_copy, order: order, final: true)
      oc2 = create(:order_copy, order: order, final: true)
      oc2.copy.stock = 0
      oc2.copy.save
      order.finalize
      oc1.reload.final.should == true
      oc2.reload.final.should == false
    end

    describe "effects to order copies" do
       before do
        # Used copy default price - 50, new copy - 100
        @oc1 = create(:order_copy, order: order)
        @oc2 = create(:order_copy, order: order, final: true)
        @oc3 = create(:order_copy, order: order, final: true, copy: create(:new_copy_with_book))
        @oc4 = create(:order_copy, order: order, final: true, copy: create(:new_copy_with_book, stock: 4), number: 2)
      end
    
      context "with postage" do
        it "calculates amounts from stocked and finalized copies" do
          order.finalize
          order.postage_amount.should == 40
          order.total_amount.should == 290
        end
      end

      context "without postage" do
        before do 
          order.customer.delivery_method = 2
          order.customer.pickup_point = create(:pickup_point)
        end

        it "calculates amounts from stocked and finalized copies" do
          order.finalize
          order.postage_amount.should == 0
          order.total_amount.should == 250
        end
      end

      it "should contain both finalized and unfinalized copies" do
        order.finalize
        order.order_copies.finalized.should == [@oc2, @oc4]
        order.order_copies.unfinalized.should == [@oc3]
      end

      it "should change the stock of the finalized copies and not unfinalized ones" do
        order.finalize
        @oc2.reload.copy.stock.should == 0
        @oc4.reload.copy.stock.should == 2

        @oc3.reload.copy.stock.should == 0
      end
    end

    it "sets the final attribute of the order" do
      order.finalize
      order.complete.should == true
    end

    it "sets the order confirmed date" do
      @time = DateTime.now
      DateTime.stub(:now).and_return(@time)
      order.finalize
      order.confirmed_date.should == @time
    end
  end
end