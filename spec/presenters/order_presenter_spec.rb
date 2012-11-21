require 'spec_helper'

describe OrderPresenter, type: :decorator do
  let(:order) { Order.new }
  subject {OrderPresenter.new(order, view)}

  describe "#formatted_postage_amount" do
    it "returns postage_amount, formatted to a currency" do
      order.should_receive(:postage_amount).and_return(40)
      CurrencyMethods.should_receive(:to_currency).and_return(:returned_currency)
      subject.formatted_postage_amount.should equal(:returned_currency)
    end

    it "returns 0, formatted to a currency when nil" do
      order.should_receive(:postage_amount).and_return(nil)
      CurrencyMethods.should_receive(:formatted_currency).with(0)
      subject.formatted_postage_amount
    end
  end

  describe "#formatted_total_amount" do
    it "returns total_amount, formatted to a currency" do
      order.should_receive(:total_amount).and_return(40)
      CurrencyMethods.should_receive(:to_currency).and_return(:returned_currency)
      subject.formatted_total_amount.should equal(:returned_currency)
    end

    it "returns 0, formatted to a currency when nil" do
      order.should_receive(:total_amount).and_return(nil)
      CurrencyMethods.should_receive(:formatted_currency).with(0)
      subject.formatted_total_amount
    end
  end
end