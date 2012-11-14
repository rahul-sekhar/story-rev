require 'spec_helper'

describe CompleteOrderPresenter, type: :decorator do
  let(:order) { create(:complete_order) }
  subject {CompleteOrderPresenter.new(order, view)}
  before do
    create(:valid_customer, complete_order: order)
  end

  describe "#get_url" do
    it "should return the pending order path for a pending order" do
      order.confirmed = true
      order.paid = true
      subject.get_url.should == pending_admin_orders_url(host: "testhost", selected_id: order.id)
    end

    it "should return the pending order path for a pending order" do
      order.confirmed = true
      order.paid = true
      order. posted = true
      order.packaged = true
      subject.get_url.should == admin_orders_url(host: "testhost", selected_id: order.id)
    end
  end

  it "gives a valid hash form" do
    subject.as_hash.should be_present
    subject.as_hash.should be_a Hash
  end
end