require 'spec_helper'

describe OrderCopy do
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

  describe "#final" do
    it "is invalid when blank or nil" do
      [nil, ""].each do |x|
        order_copy.final = x
        order_copy.should be_invalid, x
      end
    end

    it "is valid when either true or false" do
      [true, false].each do |x|
        order_copy.final = x
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

    describe "#price" do
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

  describe "#finalize" do
    it "raises an error if the copy is unstocked" do
      order_copy.copy = create(:used_copy_with_book, stock: 0)
      expect{ order_copy.finalize }.to raise_error
    end

    it "raises an error if final is set to false" do
      order_copy.copy = create(:used_copy_with_book)
      expect{ order_copy.finalize }.to raise_error
    end

    it "removes stock from a used copy" do
      order_copy.copy = create(:used_copy_with_book)
      order_copy.final = true
      order_copy.finalize
      order_copy.copy.reload.stock.should == 0
    end

    it "removes stock from a new copy" do
      order_copy.copy = create(:new_copy_with_book, stock: 5)
      order_copy.final = true
      order_copy.number = 3
      order_copy.finalize
      order_copy.copy.reload.stock.should == 2
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

  describe "when destroyed" do
    it "does nothing with an incomplete parent order" do
      c = create(:used_copy_with_book, stock: 0)
      oc = create(:order_copy, order: create(:order), copy: c, final: true)
      order_copy.destroy
      c.stock.should == 0
    end

    it "does nothing with an complete parent order, when not finalized" do
      c = create(:used_copy_with_book, stock: 0)
      oc = create(:order_copy, complete_order: create(:complete_order), copy: c)
      order_copy.destroy
      c.stock.should == 0
    end

    context "with a complete parent order and when finalized" do
      it "reverts used copy stocks" do
        c = create(:used_copy_with_book, stock: 1)
        oc = create(:order_copy, complete_order: create(:complete_order), copy: c, final: true)
        c.reload.stock.should == 0
        oc.destroy
        c.reload.stock.should == 1
      end

      it "reverts new copy stocks" do
        c = create(:new_copy_with_book, stock: 5)
        oc = create(:order_copy, complete_order: create(:complete_order), copy: c, final: true, number: 7)
        c.reload.stock.should == -2
        oc.destroy
        c.reload.stock.should == 5
      end

      it "recalculates the orders totals" do
        c = create(:used_copy_with_book, stock: 0)
        o = create(:complete_order)
        oc = create(:order_copy, complete_order: o, copy: c, final: true)
        oc.destroy
        o.reload.total_amount.should == 0
        o.postage_amount.should == 0
      end
    end
  end

  describe "when created" do
    it "does nothing with an incomplete parent order" do
      c = create(:used_copy_with_book)
      create(:order_copy, order: create(:order), copy: c, final: true)
      c.reload.stock.should == 1
    end

    it "does nothing with an complete parent order, when not finalized" do
      c = create(:new_copy_with_book, stock: 5)
      create(:order_copy, complete_order: create(:complete_order), copy: c, final: false, number: 3)
      c.reload.stock.should == 5
    end

    context "with a complete parent order and when finalized" do
      it "changes a new copies stock" do
        c = create(:new_copy_with_book, stock: 5)
        create(:order_copy, complete_order: create(:complete_order), copy: c, final: true, number: 3)
        c.reload.stock.should == 2
      end

      it "changes a used copies stock" do
        c = create(:used_copy_with_book)
        create(:order_copy, complete_order: create(:complete_order), copy: c, final: true)
        c.reload.stock.should == 0
      end

      it "correctly changes a used copies stock even with an incorrect number" do
        c = create(:used_copy_with_book)
        create(:order_copy, complete_order: create(:complete_order), copy: c, final: true, number: 3)
        c.reload.stock.should == 0
      end

      it "recalculates the orders totals" do
        o = create(:complete_order)
        c = create(:used_copy_with_book)
        create(:order_copy, complete_order: o, copy: c, final: true)
        o.reload.postage_amount.should == 20
        o.total_amount.should == 70
      end
    end
  end

  describe "when updated" do
    before do
      @c = create(:new_copy_with_book, stock: 6)
      @o = create(:complete_order)
      @oc = create(:order_copy, complete_order: @o, copy: @c, final: true, number: 2)
    end

    it "does nothing with an incomplete parent order" do
      @oc.complete_order = nil
      @oc.order = create(:order)
      @oc.number = 3
      @oc.save
      @c.reload.stock.should == 4
    end

    it "does nothing with an complete parent order, when not finalized" do
      @oc.final = false
      @oc.number = 5
      @oc.save
      @c.reload.stock.should == 4
    end

    context "with a complete parent order and when finalized" do
      it "reduces the copy stock if the number is increased" do
        @oc.number = 5
        @oc.save
        @c.reload.stock.should == 1
      end

      it "increases the copy stock if the number is increased" do
        @oc.number = 1
        @oc.save
        @c.reload.stock.should == 5
      end

      it "recalculates the orders totals" do
        @oc.number = 4
        @oc.save
        @o.reload.total_amount.should == 450
        @o.postage_amount.should == 50
      end
    end
  end
end