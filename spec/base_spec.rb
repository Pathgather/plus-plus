require 'spec_helper'

describe PlusPlus do
  context "with the minimal configuration" do
    it "increases the column by 1 on create" do
      user = User.create name: 'Test'
      comment = Comment.create user: user
      user.reload
      user.comments_count.should == 1
    end
  end

  it "should allow the user to specify if they want update_columns or update_attributes when a column is updated"
  it "should raise an error if the association is unknown"
  it "should raise an error if a column is not specified"
end