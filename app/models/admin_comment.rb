class AdminComment < ActiveRecord::Base
  belongs_to :user,      :class_name => "User", :foreign_key => "user_id"
  belongs_to :commenter, :class_name => "User", :foreign_key => "commenter_id"

  validates_presence_of :user_id
  validates_presence_of :body
  validates_length_of :body, :maximum => 1000
end
