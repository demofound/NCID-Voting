# Users in this case can have many roles including admins, certifiers, voters, and unprivileged. See the "ability" model.
# NOTE: there are several levels of user involvement that we have to take into account:
#       1. user is registered but hasn't confirmed their email
#       2. user is confirmed but hasn't provided registration data about their eligibility
#       3. user has provided registration data for certification but hasn't voted
#       4. user has voted but hasn't been certified
#       5. user has voted and has been certified
class User < ActiveRecord::Base
  has_many   :testimonials
  has_many   :initiatives
  has_many   :registrations

  # it's a bad idea to access votes directly from the user because, really, registrations own them.
  # the user relationship is mostly used for tallying unique votes by user for initiatives since
  # users can have many registrations and it would be difficult to tally without the user_id
  has_many   :votes

  has_many   :comments_left,   :class_name => "AdminComment", :foreign_key => "commenter_id"
  has_many   :certified_users, :class_name => "User",         :foreign_key => "certifier_id"

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

  has_paper_trail :only => [:roles_mask, :username, :email], :skip => PAPER_TRAIL_SKIP_ATTRIBUTES + [:password, :password_confirmation, :remember_me, :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :avatar, :confirmation_token, :confirmed_at, :confirmation_sent_at, :encrypted_password]

  before_save :set_defaults

  # no sense in trying to certify people who haven't passed voter registration certification
  def needs_certification?
    return (current_registration = self.current_registration) && !self.current_registration.certified?
  end

  def can_vote?
    return (current_registration = self.current_registration) && current_registration.votable?
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

  def current_registration
    return self.registrations.order("created_at DESC").limit(1).last()
  end

  def needs_registration?
    return self.registrations.empty?
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
