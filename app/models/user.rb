class User < ActiveRecord::Base
  has_many   :votes
  has_many   :testimonials
  has_many   :initiatives
  has_one    :user_meta
  has_many   :verified_users, :class_name => "User", :foreign_key => "verifier_id"
  belongs_to :verifier,       :class_name => "User", :foreign_key => "verifier_id"

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :confirmable, :trackable, :validatable, :omniauthable
  mount_uploader :avatar, AvatarUploader

  validates_presence_of   :username
  validates_uniqueness_of :username, :message => "is already taken"
  validates_format_of     :username, :message => "must be only numbers, letters, or underscores", :with => /^\w+$/i
  validates_length_of     :username, :message => "must be at least three characters", :minimum => 3

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username

  # yes, this is ripped off from Ryan Bates' Railscast
  scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0"} }
  ROLES = [:admin, :voting_official, :voter]

  has_paper_trail :only => [:roles_mask, :username, :email], :skip => PAPER_TRAIL_SKIP_ATTRIBUTES + [:password, :password_confirmation, :remember_me, :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :avatar, :confirmation_token, :confirmed_at, :confirmation_sent_at, :encrypted_password]

  before_save :set_defaults

  # basically begins the verification process - claims the user by the admin and
  # prevents access by other admins
  def lock!
    return false if self.locked?                             # already locked?
    return false if self.verifier.present?                   # already claimed?
    return false unless self.verified_at.nil?                # already verified?

    return self.update_attributes!(:verifier_id => current_user.id, :locked => true)
  end

  # verification can only occur given an admin has locked/claimed the user
  def verify!
    return false unless self.locked?                         # gotta be locked (ie. someone's done work to verify us)
    return false unless self.verified_at.nil?                # can't already be verified
    return false unless self.verifier_id == current_user.id  # gotta be the currently active user

    return self.update_attributes!(:verified_at => Time.now)
  end

  # basically unlocking is like saying "I'm abandoning my verification of this user",
  # allowing other admins to verify
  def unlock!
    return false unless self.locked?                         # gotta be locked
    return false unless self.verified_at.nil?                # can't already be verified
    return false unless self.verifier_id == current_user.id  # gotta be the currently active user

    return self.update_attributes!(:locked => false, :verifier_id => nil)
  end

  def locked?
    return self.locked.present?
  end

  def verified?
    return self.verified_at.present?
  end

  def self.recent(count)
    return User.limit(count).order("confirmed_at DESC").all
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
end
