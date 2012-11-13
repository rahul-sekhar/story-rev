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
        o.stub(:cart_amount).and_return(502)
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

  shared_examples_for "action that requires a stocked cart" do
    context "with an empty cart" do
      context "HTML request" do
        it "redirects to the shopping cart" do
          send_request
          response.should redirect_to(shopping_cart_path)
        end

        it "displays a flash notice" do
          send_request
          flash[:notice].should match "shopping cart is empty"
        end
      end

      context "AJAX request" do
        it "has a 400 status" do
          xhr_request
          response.status.should eq(400)
        end

        it "has a text message" do
          xhr_request
          response.body.should match "shopping cart is empty"
        end
      end
    end

    context "with an out of stock cart" do
      before do
        @order = create(:order)
        create(:order_copy, copy: create(:new_copy_with_book), order: @order)
      end

      context "HTML request" do
        it "redirects to the shopping cart" do
          send_request(@order.id)
          response.should redirect_to(shopping_cart_path)
        end

        it "displays a flash notice" do
          send_request(@order.id)
          flash[:notice].should match "unavailable"
        end
      end

      context "AJAX request" do
        it "has a 400 status" do
          xhr_request(@order.id)
          response.status.should eq(400)
        end

        it "has a text message" do
          xhr_request(@order.id)
          response.body.should match "unavailable"
        end
      end
    end
  end

  shared_examples_for "order step" do
    it_behaves_like "action that requires a stocked cart"

    context "with a stocked cart" do
      before do
        @order = create(:order)
        create(:order_copy, order: @order)
      end

      it "has a 200 status" do
        send_request(@order.id)
        response.status.should == 200
      end

      it "sets the step for a valid step" do
        send_request(@order.id)
        assigns[:step].should == 1
      end

      it "redirects for an invalid step" do
        send_request(@order.id, { step: 3 })
        response.should redirect_to order_step_path(step: 1)
      end

      it "creates a new customer object if one doesn't exist" do
        send_request(@order.id)
        assigns[:customer].should be_a Customer
        assigns[:customer].should be_new_record
        assigns[:customer].order.should eq(@order)
      end

      it "uses a customer object if one exists" do
        @customer = create(:customer, order: @order)
        send_request(@order.id)
        assigns[:customer].should eq(@customer)
      end

      it "sets the customer step" do
        @customer = create(:customer, order: @order)
        send_request(@order.id, { step: 2 })
        assigns[:customer].step.should == 2
      end
    end
  end

  def stub_customer(step)
    @order_stub = double("order")
    @customer_stub = double("customer")
    controller.stub(:order).and_return(@order_stub)
    @order_stub.stub(:customer).and_return(@customer_stub)
    @order_stub.stub_chain("order_copies.stocked.length").and_return(1)
    @customer_stub.stub(:step=)
    @customer_stub.stub(:step).and_return(step)
  end

  describe "GET show_step" do
    def send_request(order_id = nil, html_opts = { step: 1 })
      session = order_id.present? ? { order_id: order_id } : nil
      get :show_step, html_opts, session
    end

    def xhr_request(order_id = nil, html_opts = { step: 1 })
      session = order_id.present? ? { order_id: order_id } : nil
      xhr :get, :show_step, html_opts, session
    end

    it_behaves_like "order step"

    context "with a stocked cart" do
      before do
        @order = create(:order)
        create(:order_copy, order: @order)
      end

      it "sets the customer defaults for step 1" do
        send_request(@order.id)
        assigns[:customer].delivery_method.should == 1
      end

      it "sets the customer defaults for step 2" do
        @customer = create(:customer, order: @order)
        send_request(@order.id, { step: 2 })
        assigns[:customer].payment_method_id.should == 1
      end

      it "checks order stocks and calculates totals for step 4" do
        stub_customer(4)
        @customer_stub.stub(:set_defaults)
        @order_stub.should_receive(:check_unstocked)
        @order_stub.should_receive(:calculate_amounts)
        send_request(nil, { step: 4 })
      end
    end
  end

  describe "POST submit_step" do
    def send_request(order_id = nil, html_opts = { step: 1 })
      session = order_id.present? ? { order_id: order_id } : nil
      post :submit_step, html_opts, session
    end

    def xhr_request(order_id = nil, html_opts = { step: 1 })
      session = order_id.present? ? { order_id: order_id } : nil
      xhr :post, :submit_step, html_opts, session
    end

    it_behaves_like "order step"

    it "updates the customer with the sent params" do
      stub_customer(1)
      @customer_stub.should_receive(:update_attributes).with("test")
      send_request(nil, { step: 1, customer: "test" })
    end

    it "redirects to the next step if the update succeeds" do
      stub_customer(1)
      @customer_stub.stub(:update_attributes).and_return(true)
      send_request(nil, { step: 1 })
      response.should redirect_to order_step_path(step: 2)
    end

    it "renders the step if the update fails" do
      stub_customer(1)
      @customer_stub.stub(:update_attributes).and_return(false)
      send_request(nil, { step: 1 })
      response.should render_template "show_step"
    end
  end

  describe "POST confirmation" do
    def send_request(order_id = nil, html_opts = nil)
      session = order_id.present? ? { order_id: order_id } : nil
      post :confirmation, html_opts, session
    end

    def xhr_request(order_id = nil, html_opts = nil)
      session = order_id.present? ? { order_id: order_id } : nil
      xhr :post, :confirmation, html_opts, session
    end

    it_behaves_like "action that requires a stocked cart"

    context "with a stubbed order" do
      before do
        stub_customer(4)
        @order_stub.stub(:finalize)
        @delayer = double("mail delayer")
        OrderMailer.stub(:delay).and_return(@delayer)
        @delayer.stub(:confirmation)
        @delayer.stub(:notify_owner)
      end

      it "has a 200 status" do
        send_request
        response.status.should eq(200)
      end

      it "sets the confirmed order" do
        send_request
        assigns[:confirmed_order].should eq(@order_stub)
      end

      it "finalizes the order" do
        @order_stub.should_receive(:finalize)
        send_request
      end

      it "deletes the order_id from the session" do
        send_request(3)
        session[:order_id].should be_nil
      end

      it "sends a confirmation and notification mail" do
        @delayer.should_receive(:confirmation).with(@order_stub)
        @delayer.should_receive(:notify_owner).with(@order_stub)
        send_request
      end
    end
  end
end