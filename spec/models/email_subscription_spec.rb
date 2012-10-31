require "spec_helper"

describe EmailSubscription do
  context "valid email" do
    it "is valid" do
      %w[a@b.com blahblah@yahoo.co.in rahul@gmail.com g@blabla.tadah blah.gah@john.doe].each do |x|
        subject.email = x
        subject.should be_valid, x
      end
    end
  end

  context "blank email" do
    it "is invalid" do
      subject.email = ""
      subject.should be_invalid
    end
  end

  context "invalid emails" do
    it "is invalid" do
      %w[ab.com a@blah @blah.ca blah@. 12 asd a].each do |x|
        subject.email = x
        subject.should be_invalid, x
      end
    end
  end

  context "existing email" do
    before { EmailSubscription.create(email: "test@mailer.com") }

    it "is invalid if duplicate" do
      subject.email = "test@mailer.com"
      subject.should be_invalid
    end

    it "is valid if different" do
      subject.email = "some@other.com"
      subject.should be_valid
    end
  end

  describe "#error_message" do
    context "valid email" do
      before { subject.email = "valid@emailer.com" }

      specify "nil error message" do
        subject.error_message.should eq(nil)
      end
    end

    context "blank email" do
      before { subject.email = "" }

      specify "appropriate error message" do
        subject.error_message.should eq("Please enter an email address")
      end     
    end

    context "nil email" do
      before { subject.email = nil }

      specify "appropriate error message" do
        subject.error_message.should eq("Please enter an email address")
      end     
    end

    context "invalid email" do
      before { subject.email = "a@a" }

      specify "appropriate error message" do
        subject.error_message.should eq("Invalid email address")
      end
    end

    context "duplicate email" do
      before do
        EmailSubscription.create(email: "created@email.com")
        subject.email = "created@email.com"
      end

      specify "appropriate error message" do
        subject.error_message.should eq("You have already subscribed")
      end
    end
  end
end