# Users in this case can have many roles including admins, certifiers, voters, and unprivileged. See the "ability" model.
# NOTE: there are several levels of user involvement that we have to take into account:
#       1. user is registered but hasn't confirmed their email
#       2. user is confirmed but hasn't provided registration data about their eligibility
#       3. user has provided registration data for certification but hasn't voted
#       4. user has voted but hasn't been certified
#       5. user has voted and has been certified
class User < ActiveRecord::Base
  has_many :testimonials
  has_many :initiatives
  has_many :registrations, :order => "created_at DESC", :dependent => :destroy

  # the current registration is the registration the user is current using to vote.
  # the user can change registrations for many reasons including:
  # - they've changed address
  # - there are many people using the same account (different registrations) to vote
  # so this means that current_registration may be toggled at any time
  belongs_to :current_registration, :class_name => "Registration"

  # it's a bad idea to access votes directly from the user because, really, registrations
  # own them.  the user relationship is mostly used for tallying unique votes by user for
  # initiatives since users can have many registrations and it would be difficult to tally
  # without the user_id
  has_many :votes

  has_many :comments_left,   :class_name => "AdminComment", :foreign_key => "commenter_id"
  has_many :certified_users, :class_name => "User",         :foreign_key => "certifier_id"

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  mount_uploader :avatar, AvatarUploader

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :avatar, :current_registration_id, :registrations_attributes
  accepts_nested_attributes_for :registrations, :limit => 1

  # yes, this is ripped off from Ryan Bates' Railscast
  scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0"} }

  has_paper_trail :only => [:roles_mask, :email], :skip => PAPER_TRAIL_SKIP_ATTRIBUTES + [:password, :password_confirmation, :remember_me, :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :avatar, :confirmation_token, :confirmed_at, :confirmation_sent_at, :encrypted_password]

  ## normal methods ##

  def active_registrations
    # latest first, grab records uniquely filtered by fullname
    return self.registrations.group("fullname")
  end

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

  def needs_registration?
    return self.registrations.empty?
  end

  def change_current_registration(id)
    # make sure we only change registrations to registrations owned by the user!
    return self.update_attributes!(:current_registration_id => id) if self.registrations.where(:id => id).first
  end

  # In order to support the desired workflow (vote/account creation simultaneous -> email confirmation -> registration)
  # we need this notion of temporary votes.  Basically votes are owned by registrations, not users, so to support
  # a user being able to vote prior to registering, we need to record the vote and have a way to know to associate
  # that vote with a registration at a later time.  Temporary votes allow us to relate an as-of-yet unconfirmed user
  # with a vote that has no user or registration directly associated with it.  Then once the user registers,
  # we will fill in the registration_id.
  def temp_votes
    return self.votes.where(:registration_id => nil)
  end

  private

  def current_user
    return nil unless session = UserSession.find
    return session.user
  end
end
