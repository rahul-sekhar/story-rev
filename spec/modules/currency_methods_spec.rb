require 'spec_helper'

class DummyClass
end

describe CurrencyMethods do
  let(:dummy) { DummyClass.new.extend(CurrencyMethods) }
  
  describe "#to_currency" do
    it "should append 'Rs.' to the amount" do
      dummy.to_currency(40).should == "Rs. 40"
    end
  end

  describe "#to_currency" do
    it "should append 'Rs.' to the amount, enclosed in a span" do
      dummy.to_currency_with_span(40).should == "<span class=\"rs\">Rs.</span> 40"
    end
  end

  describe "#number_format" do
    it "should place commas in their correct positions" do
      dummy.number_format("1232145").should == "12,32,145"
      dummy.number_format(11232145).should == "1,12,32,145"
      dummy.number_format(9999).should == "9,999"
      dummy.number_format(12).should == "12"
      dummy.number_format(0).should == "0"
      dummy.number_format(124567.5464).should == "1,24,567.5464"
    end
  end

  describe "#formatted_currency" do
    it "should place commas correctly and append 'Rs.'" do
      dummy.formatted_currency(123456789).should == "Rs. 12,34,56,789"
      dummy.formatted_currency(0.67).should == "Rs. 0.67"
      dummy.formatted_currency(1245.67).should == "Rs. 1,245.67"
    end
  end
end