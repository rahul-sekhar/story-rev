require "spec_helper"

describe PagesController do
  describe "GET store" do
    it "has a 200 status code" do
      get :store
      response.code.should eq("200")
    end

    it "sets the correct title" do
      get :store
      assigns(:title).should eq("Store")
    end

    it "does not set show_shopping_cart if show_cart is not set" do
      get :store
      assigns(:show_shopping_cart).should be_nil
    end
    
    it "sets show_shopping_cart if show_cart is set" do
      get :store, show_cart: true
      assigns(:show_shopping_cart).should be_true
    end

    it "returns no books if there are no books" do
      get :store
      assigns(:books).should be_empty
    end

    it "returns no books if there are only unstocked books" do
      create_list(:book, 5)
      get :store
      assigns(:books).should be_empty
    end

    it "returns only stocked books" do
      unstocked_books = create_list(:book, 3)
      stocked_books = create_list(:book_with_used_copy, 3)
      unstocked_new_books = create_list(:new_copy_with_book, 3)
      stocked_new_books = create_list(:book_with_new_copy, 3)

      get :store
      assigns(:books).should =~ stocked_books + stocked_new_books
    end

    it "returns 20 books per page" do
      create_list(:book_with_used_copy, 21)
      get :store
      assigns(:books).length.should eq(20)
    end

    it "deletes the price parameter if price_to is set" do
      get :store, price: "60-70", price_to: "40"
      controller.params[:price].should be_nil
      controller.params[:price_to].should == "40"
    end

    it "deletes the price parameter if price_from is set" do
      get :store, price: "60-70", price_from: "30"
      controller.params[:price].should be_nil
      controller.params[:price_from].should == "30"
    end

    it "keeps the price parameter if price_to and price_from are not set" do
      get :store, price: "60-70"
      controller.params[:price].should == "60-70"
    end

    describe "seed parameter" do
      context "sort by is not random" do
        it "deletes the seed parameter if sort_by is not random" do
          get :store, seed: "156", sort_by: "date"
          controller.params[:seed].should be_nil
        end
      end

      context "sort by is random" do
        it "keeps the seed parameter if present" do
          get :store, seed: "156", sort_by: "random"
          controller.params[:seed].should == "156"
        end

        it "sets a new seed parameter between 1 and 999 if not present" do
          get :store, sort_by: "random"
          seed = controller.params[:seed].to_i
          seed.should > 0
          seed.should < 1000
        end

        it "sets a new seed parameter if the seed is not an integer" do
          get :store, sort_by: "random", seed: "eh"
          seed = controller.params[:seed].to_i
          seed.should > 0
          seed.should < 1000
        end

        it "sets a new seed parameter if the seed is above 999" do
          get :store, sort_by: "random", seed: "1000"
          seed = controller.params[:seed].to_i
          seed.should > 0
          seed.should < 1000
        end
      end
    end

    describe "list of book types" do
      it "returns only prioritised book types, ordered by priority" do
        b1 = create(:book_with_new_copy)
        b2 = create(:book_with_new_copy)
        b3 = create(:book_with_new_copy)
        b4 = create(:book_with_new_copy)

        bt1 = create(:book_type, books: [b1], priority: 3)
        bt2 = create(:book_type, books: [b2])
        bt3 = create(:book_type, books: [b3], priority: 1)
        bt4 = create(:book_type, books: [b4], priority: 10)

        get :store
        assigns(:book_types).should == [bt4, bt1, bt3]
      end

      it "ignores book types not attached to a stocked book" do
        b1 = create(:book_with_used_copy)
        b2 = create(:book)
        b3 = create(:book_with_used_copy)
        c = b3.used_copies.first
        c.stock = 0
        c.save
        b4 = create(:book_with_used_copy)

        bt1 = create(:book_type, priority: 1)
        bt2 = create(:book_type, priority: 1, books: [b1, b4])
        bt3 = create(:book_type, priority: 1, books: [b2])
        bt4 = create(:book_type, priority: 1, books: [b3])

        get :store
        assigns(:book_types).should == [bt2]
      end
    end

    describe "list of collections" do
      it "returns only prioritised collections, ordered by priority" do
        b1 = create(:book_with_new_copy)
        b2 = create(:book_with_new_copy)
        b3 = create(:book_with_new_copy)
        b4 = create(:book_with_new_copy)

        c1 = create(:collection, books: [b1], priority: 3)
        c2 = create(:collection, books: [b2])
        c3 = create(:collection, books: [b3], priority: 1)
        c4 = create(:collection, books: [b4], priority: 10)

        get :store
        assigns(:collections).should == [c4, c1, c3]
      end

      it "ignores collections not attached to a stocked book" do
        b1 = create(:book_with_used_copy)
        b2 = create(:book)
        b3 = create(:book_with_used_copy)
        c = b3.used_copies.first
        c.stock = 0
        c.save
        b4 = create(:book_with_used_copy)

        c1 = create(:collection, priority: 1)
        c2 = create(:collection, priority: 1, books: [b1, b4])
        c3 = create(:collection, priority: 1, books: [b2])
        c4 = create(:collection, priority: 1, books: [b3])

        get :store
        assigns(:collections).should == [c2]
      end
    end

    describe "list of formats" do
      it "ignores formats not attached to a stocked edition" do
        (f1, f2, f3, f4, f5) = create_list(:format, 5)

        b1 = create(:book)
        create(:edition_with_used_copy, book: b1, format: f1)
        e = create(:edition, book: b1, format: f2)
        create(:used_copy, stock: 0, edition: e)
        create(:edition_with_new_copy, book: create(:book), format: f3)
        create(:edition_with_new_copy, book: create(:book), format: f5)
        create(:edition_with_used_copy, book: create(:book), format: f5)

        get :store
        assigns(:formats).should =~ [f1,f3, f5]
      end
    end

    it ""
  end

  describe "POST subscribe" do
    before do
      Delayed::Worker.delay_jobs = false
      @email_deliveries = ActionMailer::Base.deliveries.size
    end

    shared_examples "sends subscription emails" do
      it "sends two emails" do
        ActionMailer::Base.deliveries.size.should eq(@email_deliveries + 2)
      end

      describe "user mail" do
        let(:user_mail) {ActionMailer::Base.deliveries[-2]}

        it "is sent to the user" do
          user_mail.to.should eq(["test@email.com"])
        end

        it "is sent from the owners email" do
          user_mail.from.should eq(["contact@storyrevolution.in"])
        end

        it "has the correct subject" do
          user_mail.subject.should eq("You are subscribed to updates")
        end
      end

      describe "owner mail" do
        let(:owner_mail) {ActionMailer::Base.deliveries[-1]}

        it "is sent to the owner" do
          owner_mail.to.should eq(["contact@storyrevolution.in"])
        end

        it "is sent from the user" do
          owner_mail.from.should eq(["test@email.com"])
        end

        it "has the correct subject" do
          owner_mail.subject.should eq("Story Revolution Subscription")
        end

        it "should contain the users email address" do
          owner_mail.body.encoded.should match("test@email.com")
        end
      end
    end
    
    context "HTML request" do
      context "valid email" do
        before do
          post :subscribe, email: "test@email.com"
        end

        it "redirects to the home page footer" do
          response.should redirect_to(root_path anchor: 'page-footer')
        end

        it "sets subscribed in the flash" do
          flash[:subscribed].should eq(true)
        end

        it "does not set a subscription error" do
          flash[:subscription_error].should eq(nil)
        end

        it "creates an email subscription" do
          EmailSubscription.where(email: "test@email.com").count.should eq(1)
        end

        include_examples "sends subscription emails"
      end

      shared_examples "invalid subscription" do
        it "redirects to the home page footer" do
          response.should redirect_to(root_path anchor: 'page-footer')
        end

        it "does not set subscribed in the flash" do
          flash[:subscribed].should eq(nil)
        end

        it "does not create an email subscription" do
          EmailSubscription.count.should eq(@email_count || 0)
        end

        it "does not send any emails" do
          ActionMailer::Base.deliveries.size.should eq(@email_deliveries + 0)
        end
      end

      context "invalid email" do
        before do
          post :subscribe, email: "test@email"
        end

        it_behaves_like "invalid subscription"

        it "sets the correct error in the flash" do
          flash[:subscription_error].should eq("Invalid email address")
        end
      end

      context "blank email" do
        before do
          post :subscribe, email: ""
        end

        it_behaves_like "invalid subscription"

        it "sets the correct error in the flash" do
          flash[:subscription_error].should eq("Please enter an email address")
        end
      end

      context "no email param" do
        before do
          post :subscribe
        end

        it_behaves_like "invalid subscription"

        it "sets the correct error in the flash" do
          flash[:subscription_error].should eq("Please enter an email address")
        end
      end

      context "duplicate email" do
        before do
          EmailSubscription.create(email: "test@email.com")
          @email_count = 1
          post :subscribe, email: "test@email.com"
        end

        it_behaves_like "invalid subscription"

        it "sets the correct error in the flash" do
          flash[:subscription_error].should eq("You have already subscribed")
        end
      end
    end

    context "JSON request" do

      def json_response
        ActiveSupport::JSON.decode response.body
      end

      context "valid email" do
        before do
          post :subscribe, email: "test@email.com", format: :json
        end

        it "has a 200 status code" do
          response.code.should eq("200")
        end

        it "reports success in the response" do
          json_response['success'].should eq(true)
        end

        it "has no error message in the response" do
          json_response['error'].should eq(nil)
        end

        it "creates an email subscription" do
          EmailSubscription.where(email: "test@email.com").count.should eq(1)
        end

        include_examples "sends subscription emails"
      end


      shared_examples "json invalid subscription" do
        it "has a 200 status code" do
          response.code.should eq("200")
        end

        it "does not report success in the response" do
          json_response['success'].should eq(nil)
        end

        it "does not create an email subscription" do
          EmailSubscription.count.should eq(@email_count || 0)
        end

        it "does not send any emails" do
          ActionMailer::Base.deliveries.size.should eq(@email_deliveries + 0)
        end
      end

      context "invalid email" do
        before do
          post :subscribe, email: "test@email", format: :json
        end

        it_behaves_like "json invalid subscription"

        it "responds with an error message" do
          json_response['error'].should eq("Invalid email address")
        end
      end

      context "blank email" do
        before do
          post :subscribe, email: "", format: :json
        end

        it_behaves_like "json invalid subscription"

        it "responds with an error message" do
          json_response['error'].should eq("Please enter an email address")
        end
      end

      context "no email param" do
        before do
          post :subscribe, format: :json
        end

        it_behaves_like "json invalid subscription"

        it "responds with an error message" do
          json_response['error'].should eq("Please enter an email address")
        end
      end

      context "duplicate email" do
        before do
          EmailSubscription.create(email: "test@email.com")
          @email_count = 1
          post :subscribe, email: "test@email.com", format: :json
        end

        it_behaves_like "json invalid subscription"

        it "responds with an error message" do
          json_response['error'].should eq("You have already subscribed")
        end
      end
    end
  end

  describe "GET about" do
    it "has a 200 status code" do
      get :about
      response.code.should eq("200")
    end

    it "sets a title" do
      get :about
      assigns(:title).should eq("About")
    end
  end

  describe "GET help" do
    it "has a 200 status code" do
      get :help
      response.code.should eq("200")
    end

    it "sets a title" do
      get :help
      assigns(:title).should eq("Help")
    end
  end
end