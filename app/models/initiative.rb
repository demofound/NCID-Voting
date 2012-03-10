class Initiative < ActiveRecord::Base
  has_one  :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :votes

  validates_presence_of   :name
  validates_presence_of   :code
  validates_presence_of   :user
  validates_uniqueness_of :code, :message => "has to be unique"
end
