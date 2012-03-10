class Initiative < ActiveRecord::Base
  has_one  :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :votes

  before_save       :set_defaults
  before_validation :generate_code

  validates_presence_of   :name
  validates_presence_of   :code
  validates_presence_of   :user_id
  validates_uniqueness_of :code, :message => "is already in use"

  private

  def set_defaults
    self.start_at ||= Time.now
  end

  # basically strips white space, normalizes down to alpha characters with underscores
  # NOTE: *should* be URI safe (if it isn't fix it)
  def generate_code
    self.code ||= self.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').to_s.gsub(/\W+/,"_").downcase
  end
end
