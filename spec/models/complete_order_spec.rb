require 'spec_helper'

describe CompleteOrder do
  let(:built_order) { build(:complete_order) }
  let(:order) { create(:complete_order) }
  subject { order }

  it { should be_valid }

  it "only returns orders with complete set to true" do
    o1 = create(:complete_order, complete: false)
    o2 = create(:complete_order, complete: true)
    CompleteOrder.all.should == [o2]
  end

  it "should set the confirmed date on creation" do
    @time = DateTime.now
    DateTime.stub(:now).and_return @time
    order.confirmed_date.should == @time
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

  describe "#postage_expenditure" do
    it "defaults to 0" do
      built_order.postage_expenditure.should == 0
    end

    it "cannot be nil" do
      built_order.postage_expenditure = nil
      built_order.should be_invalid
    end

    it "cannot be negative" do
      built_order.postage_expenditure = -1
      built_order.should be_invalid
    end

    it "can be zero" do
      built_order.postage_expenditure = 0
      built_order.should be_valid
    end
    
    it "can be a positive integer" do
      built_order.postage_expenditure = 40
      built_order.should be_valid
    end
  end

  describe "#complete" do
    it "defaults to true" do
      built_order.complete.should == true
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

  describe "#add_copy" do
    before do
      create(:valid_customer, complete_order: order)
    end

    it "does not work unless the order is saved" do
      c = create(:used_copy_with_book)
      expect{ CompleteOrder.new.add_copy = c.id }.to raise_exception(ActiveRecord::RecordNotSaved)
    end

    it "adds a copy to the order" do
      c = create(:used_copy_with_book)
      order.add_copy = c.id
      order.used_copies.should == [c]
    end

    it "adds a finalized order_copy" do
      c = create(:used_copy_with_book)
      order.add_copy = c.id
      OrderCopy.last.final.should == true
    end

    it "changes the stock of an added used copy" do
      c = create(:used_copy_with_book)
      order.add_copy = c.id
      c.reload.stock.should == 0
    end

    it "changes the stock of an added new copy" do
      c = create(:new_copy_with_book, stock: 2)
      order.add_copy = c.id
      c.reload.stock.should == 1
    end

    it "calculates the order total" do
      c = create(:new_copy_with_book, stock: 2)
      order.add_copy = c.id
      order.reload.postage_amount.should == 20
      order.reload.total_amount.should == 120
    end

    it "does not add a used copy if already present" do
      c = create(:used_copy_with_book)
      order.add_copy = c.id
      order.add_copy = c.id
      order.used_copies.should == [c]
      order.order_copies.length.should == 1
      c.reload.stock.should == 0
    end

    it "does not add a new copy if already present" do
      c = create(:new_copy_with_book, stock: 3)
      order.add_copy = c.id
      order.add_copy = c.id
      order.new_copies.should == [c]
      order.order_copies.length.should == 1
      c.reload.stock.should == 2
    end
  end

  describe "#remove_copy" do
    before do
      create(:valid_customer, complete_order: order)
    end

    it "removes a copy from the order, given its id" do
      c = create(:used_copy_with_book)
      create(:order_copy, complete_order: order, copy: c, final: true)
      order.remove_copy = c.id
      order.used_copies.should be_empty
    end

    it "reverts a used copies stock" do
      c = create(:used_copy_with_book)
      oc = create(:order_copy, complete_order: order, copy: c, final: true)
      c.reload.stock.should == 0
      order.remove_copy = c.id
      c.reload.stock.should == 1
    end

    it "reverts a new copies stock" do
      c = create(:new_copy_with_book)
      oc = create(:order_copy, complete_order: order, copy: c, number: 2, final: true)
      c.reload.stock.should == -2
      order.remove_copy = c.id
      c.reload.stock.should == 0
    end

    it "recalculates totals" do
      c = create(:new_copy_with_book)
      oc = create(:order_copy, complete_order: order, copy: c, number: 2, final: true)
      order.reload.total_amount.should == 230
      order.remove_copy = c.id
      order.reload.total_amount.should == 0
    end
  end

  context "when destroyed" do
    before do
      create(:valid_customer, complete_order: order)
    end
    it "destroys its customer" do
      expect{ order.destroy }.to change{Customer.count}.by(-1)
    end

    it "destroys any order copies present" do
      create(:order_copy, complete_order: order, copy: create(:used_copy_with_book))
      create(:order_copy, complete_order: order, copy: create(:new_copy_with_book), final: true)
      expect{ order.destroy }.to change{OrderCopy.count}.by(-2)
    end

    it "does not destroy copies" do
      create(:order_copy, complete_order: order, copy: create(:used_copy_with_book))
      create(:order_copy, complete_order: order, copy: create(:new_copy_with_book), final: true)
      expect{ order.destroy }.to change{Copy.count}.by(0)
    end

    it "reverts any finalized copies" do
      c1 = create(:used_copy_with_book, stock: 0)
      c2 = create(:new_copy_with_book, stock: 3)
      c3 = create(:new_copy_with_book, stock: 5)
      c4 = create(:used_copy_with_book, stock: 1)
      create(:order_copy, complete_order: order, copy: c1)
      create(:order_copy, complete_order: order, copy: c2, number: 2)
      create(:order_copy, complete_order: order, copy: c3, number: 3, final: true)
      create(:order_copy, complete_order: order, copy: c4, final: true)
      c1.reload.stock.should == 0
      c2.reload.stock.should == 3
      c3.reload.stock.should == 2
      c4.reload.stock.should == 0
      order.destroy
      c1.reload.stock.should == 0
      c2.reload.stock.should == 3
      c3.reload.stock.should == 5
      c4.reload.stock.should == 1
    end

    it "destroys any extra costs" do
      create_list(:extra_cost, 3, complete_order: order)
      expect{ order.destroy }.to change{ExtraCost.count}.by(-3)
    end

    it "destroys any transactions" do
      order.update_attributes(paid: true)
      expect{ order.destroy }.to change{Transaction.count}.by(-1)
    end
  end

  describe "#order_copies" do
    it "contains only finalized order_copies" do
      create(:valid_customer, complete_order: order)
      oc1 = create(:order_copy, complete_order: order, copy: create(:used_copy_with_book))
      oc2 = create(:order_copy, complete_order: order, copy: create(:new_copy_with_book), final: true)
      order.order_copies.should == [oc2]
    end
  end

  describe "#unfinalized_order_copies" do
    it "contains only unfinalized order_copies" do
      create(:valid_customer, complete_order: order)
      oc1 = create(:order_copy, complete_order: order, copy: create(:used_copy_with_book))
      oc2 = create(:order_copy, complete_order: order, copy: create(:new_copy_with_book), final: true)
      order.unfinalized_order_copies.should == [oc1]
    end
  end

  describe "#recalculate" do
    before do
      create(:valid_customer, delivery_method: 1, complete_order: order)
      create(:order_copy, copy: create(:used_copy_with_book, price: 50), complete_order: order, final: true)
      create(:order_copy, copy: create(:used_copy_with_book, price: 100), complete_order: order, final: false)
      create(:order_copy, copy: create(:new_copy_with_book, stock: 5, price: 120), complete_order: order, number: 3, final: true)
      create(:order_copy, copy: create(:used_copy_with_book, price: 90, stock: 0), complete_order: order, final: true)
      create(:order_copy, copy: create(:new_copy_with_book, price: 80), complete_order: order, number: 1, final: false)
    end

    describe "without postage" do
      before{ order.customer.delivery_method = 2 }

      it "gives the correct totals" do
        order.recalculate
        order.postage_amount.should == 0
        order.total_amount.should == 500
      end
    end

    it "gives the correct total of order copies with postage" do
        order.recalculate
        order.postage_amount.should == 60
        order.total_amount.should == 560
      end

    it "takes extra costs into account" do
      create(:extra_cost, complete_order: order, amount: 40, expenditure: 10)
      create(:extra_cost, complete_order: order, amount: 20, expenditure: 20)
      order.recalculate
      order.postage_amount.should == 60
      order.total_amount.should == 620
    end
  end

  describe "scopes" do
    before do
      @o1 = create(:complete_order)
      @o2 = create(:complete_order_with_customer, posted_date: 1.minute.ago, confirmed_date: Time.now - 2.days, posted_date: Time.now + 2.days)
      @o2.paid_date = 1.day.ago
      @o2.save
      @o3 = create(:complete_order, confirmed_date: 1.day.ago)
      @o4 = create(:complete_order_with_customer, confirmed_date: Time.now - 2.days)
      @o4.paid_date = 1.day.ago
      @o4.save
    end

    specify "finalized gets orders that have been confirmed, paid, packaged and posted" do
      CompleteOrder.finalized.should == [@o2]
    end

    specify "unfinalized gets orders that have not been confirmed, paid, packaged or posted" do
      CompleteOrder.unfinalized.should =~ [@o1, @o3, @o4]
    end
  end

  describe "#number_of_copies" do
    it "returns 0 when there are no copies" do
      order.number_of_copies.should == 0
    end

    it "totals up the number of copies for finalized order copies" do
      create(:valid_customer, complete_order: order)
      create(:order_copy, complete_order: order, final: true)
      create(:order_copy, complete_order: order, final: false)
      create(:order_copy, copy: create(:new_copy_with_book, stock: 5), complete_order: order, number: 3, final: true)
      create(:order_copy, copy: create(:new_copy_with_book, stock: 2), complete_order: order, number: 1, final: false)

      order.number_of_copies.should == 4
    end
  end

  shared_examples_for "a date attribute that is accessible as a boolean" do
    def get_date_attr
      order.send("#{attrib}_date")
    end
    def set_date_attr(val)
      order.send("#{attrib}_date=", val)
    end
    def get_attr
      order.send(attrib)
    end
    def set_attr(val)
      order.send("#{attrib}=", val)
    end

    it "returns true if the date is present" do
      set_date_attr(1.month.ago)
      get_attr.should == true
    end

    it "returns false if the date is not present" do
      set_date_attr(nil)
      get_attr.should == false
    end

    context "if the date is not set" do
      before do
        @time = DateTime.now
        DateTime.stub(:now).and_return(@time)
      end
      
      it "sets the date to the current time when set to true" do
        set_attr(true)
        get_date_attr.should == @time
      end

      it "sets the date to nil when set to false" do
        set_attr(false)
        get_date_attr.should == nil
      end

      it "sets the date to nil when set to 'false'" do
        set_attr('false')
        get_date_attr.should == nil
      end
    end

    context "if the date is already set" do
      before do
        @earlier_time = 1.day.ago
        set_date_attr(@earlier_time)
      end
      
      it "leaves the date unchanged set to true" do
        set_attr(true)
        get_date_attr.should == @earlier_time
      end

      it "sets the date to nil when set to false" do
        set_attr(false)
        get_date_attr.should == nil
      end

      it "sets the date to nil when set to 'false'" do
        set_attr('false')
        get_date_attr.should == nil
      end
    end
  end

  describe "#confirmed" do
    let(:attrib){ "confirmed" }
      
    it_behaves_like "a date attribute that is accessible as a boolean"
  end

  describe "#paid" do
    let(:attrib){ "paid" }
      
    it_behaves_like "a date attribute that is accessible as a boolean"
  end

  describe "#packaged" do
    let(:attrib){ "packaged" }
      
    it_behaves_like "a date attribute that is accessible as a boolean"
  end

  describe "#posted" do
    let(:attrib){ "posted" }
      
    it_behaves_like "a date attribute that is accessible as a boolean"
  end

  describe "when saved" do
    before do
      @date = 1.day.ago
      create(:valid_customer, complete_order: order)
      order.reload.customer.name = "Test"
      order.customer.payment_method = create(:payment_method, id: 1)
      order.customer.notes = "Some notes"
      order.customer.save
      order.postage_expenditure = 20
      create(:extra_cost, complete_order: order, amount: 60, expenditure: 30)
    end

    context "with paid date set" do
      before { order.paid_date = @date }

      context "with an existing transaction" do
        before { @t = create(:transaction, complete_order: order, credit: 20, debit: 0) }

        it "causes does not create a transaction" do
          expect{ order.save }.to change{Transaction.count}.by(0)
        end

        describe "the updated transaction" do
          subject{ @t.reload }
          before{ order.save }
          
          it "has the right date" do
            subject.date.should == @date
          end
          
          it "has the right other_party" do
            subject.other_party.should == "Test"
          end

          it "has the right payment_method_id" do
            subject.payment_method_id.should == 1
          end

          it "has the right notes" do
            subject.notes.should == "Some notes"
          end

          it "has the right credit" do
            subject.credit.should == 60
          end

          it "has the right debit" do
            subject.debit.should == 50
          end

          it "has the right order" do
            subject.complete_order.should == order
          end
        end
      end

      context "without an existing transaction" do
        it "causes a transaction to be created" do
          expect{ order.save }.to change{Transaction.count}.by(1)
        end

        describe "the created transaction" do
          subject{ order.transaction }
          before{ order.save }
          
          it "has the right date" do
            subject.date.should == @date
          end
          
          it "has the right other_party" do
            subject.other_party.should == "Test"
          end

          it "has the right payment_method_id" do
            subject.payment_method_id.should == 1
          end

          it "has the right notes" do
            subject.notes.should == "Some notes"
          end

          it "has the right credit" do
            subject.credit.should == 60
          end

          it "has the right debit" do
            subject.debit.should == 50
          end

          it "has the right order" do
            subject.complete_order.should == order
          end
        end
      end
    end

    context "without paid date set" do
      context "with an existing transaction" do
        before do 
          order.paid = true
          order.save
          order.paid = false
        end

        it "destroys the transaction" do
          expect{ order.save }.to change{Transaction.count}.by(-1)
        end
      end

      context "without an existing transaction" do
        it "does nothing" do
          expect{ order.save }.to change{Transaction.count}.by(0)
        end
      end
    end
  end
end