class Country < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :code
  validates_format_of   :code, :with => /^[A-Z]+$/
  validates_length_of   :code, :is => 2
end
