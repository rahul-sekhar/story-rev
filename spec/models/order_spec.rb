require 'spec_helper'

describe Order, :focus do
  let(:order) { create(:order) }
  subject { order }

  it { should be_valid }

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
    before{ order.customer = create(:customer) }

    describe "amount calculation without postage" do
      before{ order.customer.delivery_method = 2 }

      it "totals the price of the order copies" do
        create(:order_copy, copy: create(:used_copy_with_book, price: 50), order: order)
        create(:order_copy, copy: create(:used_copy_with_book, price: 100), order: order)
        create(:order_copy, copy: create(:new_copy_with_book, stock: 5, price: 120), order: order, number: 3)
        order.calculate_amounts
        order.total_amount.should == 510
      end

      it "ignores unstocked copies by default" do
        create(:order_copy, copy: create(:used_copy_with_book, price: 50), order: order)
        create(:order_copy, copy: create(:used_copy_with_book, price: 100, stock: 0), order: order)
        create(:order_copy, copy: create(:new_copy_with_book, price: 120), order: order, number: 3)
        order.calculate_amounts
        order.total_amount.should == 50
      end
    end

    describe "amount calculation with postage" do
      before{ order.customer.delivery_method = 1 }

      it "totals the price of the order copies including postage" do
        create(:order_copy, copy: create(:used_copy_with_book, price: 50), order: order)
        create(:order_copy, copy: create(:used_copy_with_book, price: 100), order: order)
        create(:order_copy, copy: create(:new_copy_with_book, stock: 5, price: 120), order: order, number: 3)
        create(:order_copy, copy: create(:used_copy_with_book, price: 150, stock: 0), order: order)
        order.calculate_amounts
        order.postage_amount.should == 60
        order.total_amount.should == 570
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
      o1 = Order.new
      o1.final = true
      o1.updated_at = 14.days.ago - 1.minute
      o1.save
      o2 = Order.new
      o2.final = true
      o2.updated_at = 14.days.ago + 1.minute
      o2.save

      Order.clear_old(true)

      Order.find_by_id(o1.id).should == o1
      Order.find_by_id(o2.id).should == o2
    end
  end
end