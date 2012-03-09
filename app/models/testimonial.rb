class Testimonial < ActiveRecord::Base
  belongs_to :user

  before_save :set_state_default
  enum_attr :state, %w(unapproved approved featured)

  private

  # can't seem to find a :default option for enumerated_attribute so this will have to do
  def set_state_default
    self.state = :unapproved if self.state.nil?
  end
end
