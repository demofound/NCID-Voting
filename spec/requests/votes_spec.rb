require 'spec_helper'

describe "Votes" do
  describe "GET /ncid/vote without a session" do
    it "redirects to the login screen" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get new_vote_path(:initiative_code => Initiative.first.code)
      response.should redirect_to(new_user_session_path)
    end
  end
end
