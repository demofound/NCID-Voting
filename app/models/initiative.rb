class Initiative < ActiveRecord::Base
  belongs_to  :creator, :class_name => "User", :foreign_key => "user_id"
  has_many :votes

  before_save       :set_defaults
  before_validation :generate_code

  validates_presence_of   :name
  validates_presence_of   :code
  validates_presence_of   :user_id
  validates_presence_of   :votes_needed
  validates_uniqueness_of :code, :message => "is already in use"

  has_paper_trail :skip => PAPER_TRAIL_SKIP_ATTRIBUTES

  attr_protected :creator

  def vote_count
    # since users can have many votes for an initiative (if they have multiple
    # registrations), we need to ensure our tally only counts votes in the scope of unique
    # registrations, which for now I'm defining as having unique fullnames in the scope of
    # a user.
    # NOTE: MySQL Group By is case insensitive, so this saves our ass a bit here
    return Vote.find_by_sql("SELECT COUNT(votes.user_id) AS votes_per_user FROM votes INNER JOIN registrations ON registrations.id = votes.registration_id WHERE initiative_id = #{self.id} AND registrations.certification IS true GROUP BY registrations.user_id,registrations.fullname;").count
  end

  private

  def self.active(count)
    return Initiative.limit(count).order("created_at DESC").where("end_at < ? OR end_at is null", Time.now).all
  end

  def set_defaults
    self.start_at ||= Time.now
  end

  # basically strips white space, normalizes down to alpha characters with underscores
  # NOTE: *should* be URI safe (if it isn't fix it)
  def generate_code
    self.code ||= self.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').to_s.gsub(/\W+/,"_").downcase
  end
end
