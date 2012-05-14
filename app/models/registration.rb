class Registration < ActiveRecord::Base
  has_many   :votes
  has_many   :admin_comments,  :class_name => "AdminComment", :foreign_key => "registration_id",     :order => "created_at DESC"

  belongs_to :certifier,       :class_name => "User",         :foreign_key => "certifier_id"
  belongs_to :user
  belongs_to :state

  attr_encrypted :ssn,            :key => ATTR_ENCRYPTED_KEY, :algorithm => ATTR_ENCRYPTED_CIPHER
  attr_encrypted :street_address, :key => ATTR_ENCRYPTED_KEY, :algorithm => ATTR_ENCRYPTED_CIPHER

  attr_accessible :certifier_id, :locked, :certified_at, :certification, :needs_review, :fullname, :ssn, :street_address, :postal_code, :country_code, :state_id, :user_id

  # some of these attributes are encrypted but eh, let's store their changes anyway
  has_paper_trail

  before_validation :derive_country

  # if we have an associated state and if that associated state requires the fields in question
  validates_presence_of   :ssn,            :if => Proc.new { |r| r.state_id && r.state.required_fields.include?(:ssn_last_four)}
  validates_length_of     :ssn,            :is => 4,            :allow_nil => true # we only collect the last four digits
  validates_format_of     :ssn,            :with => /^[0-9]+$/, :allow_nil => true
  validates_presence_of   :street_address
  validates_presence_of   :postal_code
  validates_presence_of   :country_code
  validates_format_of     :country_code,   :with => /^[A-Z]+$/
  validates_presence_of   :user_id
  validates_presence_of   :fullname  # no point in trying to validate internationalizable names with regex or anything

  # basically begins the certification process - claims the user by the admin and
  # prevents access by other admins
  def lock!(certifier)
    return false if self.locked?                              # already locked?
    return false if self.certifier.present?                   # already claimed?
    return false unless self.certified_at.nil?                # already certified?

    return self.update_attributes!(:certifier_id => certifier.id, :locked => true)
  end

  # certification can only occur given an admin has locked/claimed the user
  # - should pass in true if the certification is affirmative for eligibility
  def certify!(certifier, is_eligible = false)
    return false unless self.locked?                      # gotta be locked (ie. someone's done work to certify us)
    return false unless self.certified_at.nil?            # can't already be certified
    return false unless self.certifier_id == certifier.id # gotta be the currently active user

    return self.update_attributes!(:certified_at => Time.now, :certification => is_eligible, :locked => false)
  end

  # basically unlocking is like saying "I'm abandoning my certification of this user",
  # allowing other admins to certify
  def unlock!(certifier)
    return false unless self.locked?                          # gotta be locked
    return false unless self.certified_at.nil?                # can't already be certified
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
    return self.certification.present?
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

  def derive_country
    # right now we'll assume that the existance of a state record indicates the address is in the US
    if self.state.present?
      self.country_code ||= "US"
    end
  end
end
