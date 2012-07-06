require 'spec_helper'

describe Admin::Role do
  before do
    # Create admin roles, bypassing validation
    ar = Admin::Role.new
    ar.name = "admin"
    ar.password = "admin_pass"
    ar.save(:validate => false)

    ar = Admin::Role.new
    ar.name = "team"
    ar.password = "team_pass"
    ar.save(:validate => false)
  end

  it "should return the correct role given a password" do
    Admin::Role.authenticate("admin_pass").should == "admin"
    Admin::Role.authenticate("team_pass").should == "team"
  end

  it "should return nil for an invalid password" do
    Admin::Role.authenticate("other_pass").should be_nil
  end

  describe "Changing the password" do
    let(:team_role) { Admin::Role.find_by_name("team") }
    
    before do
      team_role.password = "new_pass"
      team_role.password_confirmation = "new_pass"
      team_role.admin_password = "admin_pass"
    end

    it "should require the admin password" do
      team_role.admin_password = nil
      team_role.should be_invalid
      team_role.errors.should have_key :admin_password
    end

    it "should require a password confirmation" do
      team_role.password_confirmation = ""
      team_role.should be_invalid
      team_role.errors.should have_key :password
    end

    it "should require a matching password confirmation" do
      team_role.password_confirmation = "blah"
      team_role.should be_invalid
      team_role.errors.should have_key :password
    end

    it "should allow a change in the password" do
      team_role.save
      Admin::Role.authenticate("team_pass").should == nil
      Admin::Role.authenticate("new_pass").should == "team"
    end
  end
end