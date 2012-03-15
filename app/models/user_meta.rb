class UserMeta < ActiveRecord::Base
  belongs_to :user
  belongs_to :state

  # if we have an associated state and if that associated state requires the fields in question
  validates_presence_of :ssn,     :if => Proc.new { |um| um.state_id && um.state.required_fields.include? :ssn_last_four }
  validates_presence_of :address, :if => Proc.new { |um| um.state_id && um.state.required_fields.include? :address }
  validates_presence_of :user_id
end
