class Registration < ActiveRecord::Base
  has_many   :votes

  belongs_to :certifier,       :class_name => "User",         :foreign_key => "certifier_id"
  belongs_to :user
  belongs_to :state

  has_one :current_for_user,   :class_name => "User",         :foreign_key => "current_registration_id"

  attr_encrypted :ssn,             :key => ATTR_ENCRYPTED_KEY, :algorithm => ATTR_ENCRYPTED_CIPHER
  attr_encrypted :street_address,  :key => ATTR_ENCRYPTED_KEY, :algorithm => ATTR_ENCRYPTED_CIPHER
  attr_encrypted :drivers_license, :key => ATTR_ENCRYPTED_KEY, :algorithm => ATTR_ENCRYPTED_CIPHER
  attr_encrypted :dob,             :key => ATTR_ENCRYPTED_KEY, :algorithm => ATTR_ENCRYPTED_CIPHER

  attr_accessible :certifier_id, :locked, :certified_at, :certification, :needs_review, :fullname, :ssn, :street_address, :postal_code, :country_code, :state_id, :user_id, :drivers_license, :dob, :city

  # some of these attributes are encrypted but eh, let's store their changes anyway
  has_paper_trail

  after_create      :update_current_registration
  before_validation :dateify_dob
  before_validation :handle_foreign_state

  validate :dob_validity
  validate :license_or_ssn_validity

  # if we have an associated state and if that associated state requires the fields in question
  validates_presence_of   :state_id

  validates_presence_of   :dob
  validates_presence_of   :street_address
  validates_presence_of   :city
  validates_presence_of   :postal_code
  validates_presence_of   :country_code
  validates_format_of     :country_code,    :with => /^[A-Z]+$/
  validates_presence_of   :fullname  # no point in trying to validate internationalizable names with regex or anything

  # basically begins the certification process - claims the user by the admin and
  # prevents access by other admins
  def lock!(certifier)
    return false if self.locked?                              # already locked?
# NCID staff determined it was best to disable these checks to allow people to recertify things
#    return false if self.certifier.present?                   # already claimed?
#    return false unless self.certified_at.nil?                # already certified?

    return self.update_attributes!(:certifier_id => certifier.id, :locked => true)
  end

  # certification can only occur given an admin has locked/claimed the user
  # - should pass in true if the certification is affirmative for eligibility
  def certify!(certifier, is_eligible = false)
    return false unless self.locked?                      # gotta be locked (ie. someone's done work to certify us)
# NCID staff determined it was best to disable these checks to allow people to recertify things
#    return false unless self.certified_at.nil?            # can't already be certified
#    return false unless self.certifier_id == certifier.id # gotta be the currently active user

    return self.update_attributes!(:certified_at => Time.now, :certification => is_eligible, :locked => false)
  end

  # basically unlocking is like saying "I'm abandoning my certification of this user",
  # allowing other admins to certify
  def unlock!(certifier)
    return false unless self.locked?                          # gotta be locked
#    return false unless self.certified_at.nil?                # can't already be certified
    return false unless self.certifier_id == certifier.id  # gotta be the currently active user

    return self.update_attributes!(:locked => false, :certifier_id => nil)
  end

  # if you pass in a certifier, it checks to see if the registration is locked by the certifier
  # otherwise it just checks to see if the registration is locked period
  def locked?(certifier = nil)
    if certifier
      return self.certifier_id.present? && self.certifier_id != certifier.id
    end

    return self.locked.present?
  end

  # returns whether the registration has been certified
  # NOTE: this is not sufficient to determine if they can vote. use votable? for that
  def certified?
    return self.certified_at.present?
  end

  # returns whether the registration is eligible to vote
  def votable?
    # NOTE: it was requested by NCID staff to make all registrations automatically votable
    #       regardless of certification status
    return true
#    return self.certification.present?
  end

  def self.recent(count, conditions = {})
    return Registration.limit(count).order("created_at DESC").all(:conditions => conditions)
  end

  def read_vote_on_initiative(initiative_codes)
    initiative_ids = Initiative.where(:code => initiative_codes).select(:id).map(&:id)
    return self.votes.where(:initiative_id => initiative_ids).first
  end

  def cast_vote_on_initiative(initiative_code)
    initiative_id = Initiative.where(:code => initiative_code).select(:id).first.id
    return self.votes.create(:initiative_id => initiative_id, :decision => true, :user_id => self.user.id)
  end

  protected

  def license_or_ssn_validity
    # users need to provide either an ssn or a driver's license number or both
    # NOTE: no way to validate a driver's license... they're all too different
    errors.add(:drivers_license, "is required if you aren't providing an SSN") if self.ssn.blank? &&
      self.drivers_license.blank? &&
      self.state.present?

    errors.add(:ssn, "is required if you aren't providing a Driver's License Number") if self.drivers_license.blank? &&
      self.ssn.blank? &&
      self.state.present?

    # ssn must be in the right format if it's present
    errors.add(:ssn, "is the wrong format") unless self.ssn.blank? || (self.ssn.length == 4 && self.ssn.match(/^[0-9]+$/))
  end

  def dob_validity
    parts = self.dob.split("/").map{|i| i.to_i}
    errors.add(:dob, "is invalid.") unless parts.length == 3 &&
      parts[0] > 0 && parts[0] < 13 &&
      parts[1] > 0 && parts[1] < 31 &&
      parts[2] > 1900 && parts[2] < Time.now.year.to_i
  end

  # yeah, I'm doing this with strings because right now date_select is pretty broken in
  # our version of Rails with multiparameter attributes :( and besides I bet people are
  # more used to entering string formatted dates anyway
  def dateify_dob
    self.dob ||= ""
    parts    = self.dob.split("/").map{|i| i.to_i}
    self.dob = "#{parts[0].to_s.rjust(2, "0")}/#{parts[1].to_s.rjust(2, "0")}/#{parts[2]}"
  end

  def actualize_temp_votes
    self.actualize_votes
  end

  def update_current_registration
    unless self.user.update_attributes!(:current_registration_id => self.id)
      logger.error "unable to set current registration #{self.inspect} for user #{self.user.inspect}"
    end
  end

  def handle_foreign_state
    # if a non-domestic country is chosen, choosen the 'foreign' state
    if self.country_code != "US"
      self.state_id = State.where(:code => "FO").first.id
    end
  end
end
