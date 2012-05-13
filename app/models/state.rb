class State < ActiveRecord::Base
  has_many :registrations
  has_many :certify_wizard, :class_name => "CertifyWizardStep", :order => "order_index ASC"

  validates_presence_of :name
  validates_presence_of :code
  validates_format_of   :code, :with => /^[A-Z]+$/
  validates_length_of   :code, :is => 2

  scope :with_required_fields, lambda { |field| {:conditions => "required_fields_mask & #{2**STATE_REQUIRED_FIELDS.index(field.to_s)} > 0"} }

  def required_fields=(required_fields)
    return self.required_fields_mask = (required_fields.map(&:to_sym) & STATE_REQUIRED_FIELDS).map { |r| 2**STATE_REQUIRED_FIELDS.index(r) }.sum
  end

  def required_fields
    return STATE_REQUIRED_FIELDS.reject { |r| ((required_fields_mask || 0) & 2**STATE_REQUIRED_FIELDS.index(r)).zero? }
  end

  def self.all_fields
    return STATE_REQUIRED_FIELDS
  end

  def self.domestic_fields
    return STATE_DOMESTIC_ONLY_FIELDS
  end

  def self.anywhere_fields
    return STATE_ANYWHERE_FIELDS
  end
end
