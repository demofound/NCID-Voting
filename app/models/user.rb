class User < ActiveRecord::Base
  has_many   :votes
  has_many   :testimonials
  has_many   :initiatives
  has_one    :user_meta
  has_many   :certified_users, :class_name => "User", :foreign_key => "certifier_id"
  belongs_to :certifier,       :class_name => "User", :foreign_key => "certifier_id"

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :confirmable, :trackable, :validatable, :omniauthable
  mount_uploader :avatar, AvatarUploader

  validates_presence_of   :username
  validates_uniqueness_of :username, :message => "is already taken"
  validates_format_of     :username, :message => "must be only numbers, letters, or underscores", :with => /^\w+$/i
  validates_length_of     :username, :message => "must be at least three characters", :minimum => 3

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :certifier_id, :locked, :certified_at

  # yes, this is ripped off from Ryan Bates' Railscast
  scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0"} }
  ROLES = [:admin, :voting_official, :voter]

  has_paper_trail :only => [:roles_mask, :username, :email], :skip => PAPER_TRAIL_SKIP_ATTRIBUTES + [:password, :password_confirmation, :remember_me, :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :avatar, :confirmation_token, :confirmed_at, :confirmation_sent_at, :encrypted_password]

  before_save :set_defaults

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
  def certify!(certifier, eligible = false)
    return false unless self.locked?                          # gotta be locked (ie. someone's done work to certify us)
    return false unless self.certified_at.nil?                # can't already be certified
    return false unless self.certifier_id == certifier.id  # gotta be the currently active user

    return self.update_attributes!(:certified_at => Time.now, :certification => eligible)
  end

  # basically unlocking is like saying "I'm abandoning my certification of this user",
  # allowing other admins to certify
  def unlock!(certifier)
    return false unless self.locked?                          # gotta be locked
    return false unless self.certified_at.nil?                # can't already be certified
    return false unless self.certifier_id == certifier_user.id  # gotta be the currently active user

    return self.update_attributes!(:locked => false, :certifier_id => nil)
  end

  # if you pass in a certifier, it checks to see if the user is locked by the certifier
  # otherwise it just checks to see if the user is locked period
  def locked?(certifier = nil)
    if certifier
      return self.certifier_id != certifier.id
    end

    return self.locked.present?
  end

  def certified?
    return self.certified_at.present?
  end

  def self.recent(count, conditions = {})
    return User.limit(count).order("confirmed_at DESC").all(:conditions => conditions)
  end

  def read_vote_on_initiative(initiative_codes)
    initiative_ids = Initiative.where(:code => initiative_codes).select(:id).map(&:id)
    return self.votes.where(:initiative_id => initiative_ids).first
  end

  def cast_vote_on_initiative(initiative_code, decision)
    initiative_id = Initiative.where(:code => initiative_code).select(:id).first.id
    return self.votes.create(:initiative_id => initiative_id, :decision => decision)
  end

  # sets the roleset, overwriting whatever is currently assigned
  def roles=(roles)
    return self.roles_mask = (roles.map(&:to_sym) & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  # adds new roles to existing roleset
  def add_roles(roles)
    return self.roles = (self.roles + Array(roles)).uniq
  end

  # removes roles from an existing roleset
  def remove_roles(roles)
    return self.roles = (self.roles - Array(roles))
  end

  def roles
    return ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end

  def role?(role)
    return self.roles.include? role.to_sym
  end

  def needs_meta?
    return self.user_meta.nil?
  end

  private

  def set_defaults
    # if a user is confirmed, they can vote. if not, they can't do anything priviledged
    self.roles ||= self.confirmed_at.present? ? [:voter] : []
  end

  def current_user
    return nil unless session = UserSession.find
    return session.user
  end
end
