require 'spec_helper'

describe OrdersController do
  describe "GET view_cart" do
    it "has a 200 status" do
      get :view_cart
      response.status.should eq(200)
    end

    it "sets the title" do
      get :view_cart
      assigns[:title].should == "Shopping Cart"
    end

    it "sets no order copies for a new cart" do
      get :view_cart
      assigns[:order_copies].should be_empty
    end

    it "sets order copies for an existing cart" do
      c1 = create(:used_copy_with_book)
      c2 = create(:used_copy_with_book)
      o1 = create(:order)
      o2 = create(:order)
      oc1 = create(:order_copy, order: o1, copy: c1)
      oc2 = create(:order_copy, order: o2, copy: c2)
      get :view_cart, nil, { order_id: o2.id }
      assigns[:order_copies].should == [oc2]
    end

    it "orders stocked copies ahead of unstocked ones and otherwise orders by the updated date of the link" do
      c1 = create(:used_copy_with_book)
      c2 = create(:used_copy_with_book, stock: 0)
      c3 = create(:new_copy_with_book)
      c4 = create(:new_copy_with_book, stock: 1)
      o = create(:order)
      oc4 = create(:order_copy, order: o, copy: c4)
      oc1 = create(:order_copy, order: o, copy: c1)
      oc2 = create(:order_copy, order: o, copy: c2)
      oc3 = create(:order_copy, order: o, copy: c3)
      oc4.touch
      get :view_cart, nil, { order_id: o.id }
      assigns[:order_copies].should == [oc4, oc1, oc3, oc2]
    end

    context "JSON request" do
      def json_response
        ActiveSupport::JSON.decode response.body
      end

      it "returns an attribute item count with the number of items" do
        o = Order.new
        o.stub(:number_of_items).and_return(8)
        controller.stub(:order).and_return(o)
        get :view_cart, format: :json
        json_response['item_count'].should == 8
      end

      it "returns an attribute total with the total amount" do
        o = Order.new
        o.stub(:total_amount).and_return(502)
        controller.stub(:order).and_return(o)
        get :view_cart, format: :json
        json_response['total'].should == 502
      end

      it "returns a nil attribute html" do
        get :view_cart, format: :json
        json_response['html'].should be_nil
      end

      it "returns a html attribute with get_html set" do
        get :view_cart, get_html: true, format: :json
        json_response['html'].should_not be_nil
      end      
    end
  end

  describe "PUT update_cart" do
    it "saves the order if it is a new one" do
      put :update_cart
      controller.send(:order).should_not be_new_record
    end

    it "raises an exception if updating the cart fails" do
      o = Order.new
      o.stub(:update_attributes).and_return(false)
      controller.stub(:order).and_return(o)
      expect{ put :update_cart }.to raise_exception
    end

    it "redirects to the view cart page" do
      put :update_cart
      response.should redirect_to(shopping_cart_path)
    end

    it "redirects to the json view cart page for a json request" do
      put :update_cart, format: :json
      response.should redirect_to(action: :view_cart, format: :json)
    end

    it "redirects to the json view cart page for a json request, and adds the get_html param" do
      put :update_cart, get_html: true, format: :json
      response.should redirect_to(action: :view_cart, get_html: true, format: :json)
    end

    describe "adding a copy" do
      it "adds a copy to the cart" do
        o = create(:order)
        c = create(:used_copy_with_book)
        put :update_cart, { order: { add_copy: c.id }}, { order_id: o.id }
        o.used_copies.should == [c]
      end

      it "raises an error for a non existing copy" do
        o = create(:order)
        expect { 
          put :update_cart, { order: { add_copy: 1 }}, { order_id: o.id } 
        }.to raise_exception
      end
    end
    
    it "removes a copy from the cart if the copy id is passed in the remove_copy param" do
      o = create(:order)
      c = create(:used_copy_with_book)
      create(:order_copy, order: o, copy: c)

      put :update_cart, { order: { remove_copy: c.id }}, { order_id: o.id }
      o.used_copies.should be_empty
    end

    it "empties the cart if the empty param is passed" do
      o = create(:order)
      create(:order_copy, order: o, copy: create(:used_copy_with_book))
      create(:order_copy, order: o, copy: create(:new_copy_with_book))

      put :update_cart, { order: { empty: true }}, { order_id: o.id }
      o.copies.should be_empty
      OrderCopy.count.should == 0
    end
  end
end