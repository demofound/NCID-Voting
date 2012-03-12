class User < ActiveRecord::Base
  has_many :votes
  has_many :testimonials
  has_many :initiatives

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :confirmable, :trackable, :validatable, :omniauthable
  mount_uploader :avatar, AvatarUploader

  validates_presence_of   :username
  validates_uniqueness_of :username, :message => "is already taken"
  validates_format_of     :username, :message => "must be only numbers, letters, or underscores", :with => /^\w+$/i
  validates_length_of     :username, :message => "must be at least three characters", :minimum => 3
  validates_presence_of   :fullname  # no point in trying to validate internationalizable names with regex or anything

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  # yes, this is ripped off from Ryan Bates' Railscast
  scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0"} }
  ROLES = %w[admin voting_official voter]

  def read_vote_on_initiative(initiative_codes)
    initiative_ids = Initiative.where(:code => initiative_codes).select(:id).map(&:id)
    return self.votes.where(:initiative_id => initiative_ids).first
  end

  def cast_vote_on_initiative(initiative_code, decision)
    initiative_id = Initiative.where(:code => initiative_code).select(:id).first.id
    return self.votes.create(:initiative_id => initiative_id, :decision => decision)
  end

  def role_symbols
    roles.map(&:to_sym)
  end

  def roles=(roles)
    return self.roles.mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    return ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end

  def role?(role)
    return roles.include? role.to_s
  end
end
