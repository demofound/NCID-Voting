class State < ActiveRecord::Base
  has_many :user_metas

  validates_presence_of :name
  validates_presence_of :code
  validates_format_of   :code, :with => /^[A-Z]+$/
  validates_length_of   :code, :is => 2

  scope :with_required_fields, lambda { |field| {:conditions => "required_fields_mask & #{2**REQUIRED_FIELDS.index(field.to_s)} > 0"} }
  REQUIRED_FIELDS = [:fullname, :ssn_last_four, :address]

  def required_fields=(required_fields)
    return self.required_fields_mask = (required_fields.map(&:to_sym) & REQUIRED_FIELDS).map { |r| 2**REQUIRED_FIELDS.index(r) }.sum
  end

  def required_fields
    return REQUIRED_FIELDS.reject { |r| ((required_fields_mask || 0) & 2**REQUIRED_FIELDS.index(r)).zero? }
  end
end
