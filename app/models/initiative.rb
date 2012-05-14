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
    # since users can have many votes for an initiative (if they have
    # multiple registrations), we need to ensure our tally only counts votes per user
    return Vote.where(:initiative_id => self.id).select(:user_id).uniq.count
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
