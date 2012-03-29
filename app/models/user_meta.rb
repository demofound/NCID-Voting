class UserMeta < ActiveRecord::Base
  belongs_to :user
  belongs_to :state

  attr_encrypted :ssn,            :key => ATTR_ENCRYPTED_KEY, :algorithm => ATTR_ENCRYPTED_CIPHER
  attr_encrypted :street_address, :key => ATTR_ENCRYPTED_KEY, :algorithm => ATTR_ENCRYPTED_CIPHER

  # some of these attributes are encrypted but eh, let's store their changes anyway
  has_paper_trail

  before_validation :derive_country

  # if we have an associated state and if that associated state requires the fields in question
  validates_presence_of   :ssn,            :if => Proc.new { |um| um.state_id && um.state.required_fields.include?(:ssn_last_four)}
  validates_length_of     :ssn,            :is => 4,            :allow_nil => true # we only collect the last four digits
  validates_format_of     :ssn,            :with => /^[0-9]+$/, :allow_nil => true
  validates_presence_of   :street_address, :if => Proc.new { |um| um.state_id && um.state.required_fields.include?(:address) }
  validates_presence_of   :postal_code,    :if => Proc.new { |um| um.state_id && um.state.required_fields.include?(:address) }
  validates_presence_of   :country_code,   :if => Proc.new { |um| um.state_id && um.state.required_fields.include?(:address) }
  validates_format_of     :country_code,   :with => /^[A-Z]+$/
  validates_presence_of   :user_id
  validates_uniqueness_of :user_id
  validates_presence_of   :fullname  # no point in trying to validate internationalizable names with regex or anything

  private

  def derive_country
    # right now we'll assume that the existance of a state record indicates the address is in the US
    if self.state.present?
      self.country_code ||= "US"
    end
  end
end
