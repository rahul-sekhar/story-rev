require 'spec_helper'

class TestController < ApplicationController
  def test
    @order = order
  end
end

describe PagesController do
  describe "#order" do
    subject { controller.send(:order) }

    it "returns a new order with nothing in the session" do
      get :store
      subject.should be_a Order
      subject.should be_new_record
    end

    it "returns the same order after multiple calls" do
      get :store
      order1 = controller.send(:order)
      controller.send(:order).should == order1
    end

    it "returns an order by id if stored in the session" do
      order = create(:order)
      get :store, nil, { order_id: order.id }
      subject.should == order
    end

    it "returns a new order if an invalid id is stored in the session" do
      order = create(:order)
      get :store, nil, { order_id: order.id + 1 }
      subject.should be_a Order
      subject.should be_new_record
    end

    it "returns a new order if a finalized order is stored in the session" do
      order = create(:order, complete: true)
      get :store, nil, { order_id: order.id }
      subject.should be_a Order
      subject.should be_new_record
    end
  end

  describe "#store_order" do
    it "saves the order" do
      get :store
      order = controller.send(:order)
      order.should_receive(:save)
      controller.send(:store_order)
    end
    
    it "sets the session order id" do
      get :store
      order = controller.send(:order)
      controller.send(:store_order)
      session[:order_id].should == order.id
    end
  end
end