class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :initiative

  before_save :set_defaults

  validates_presence_of   :initiative,                  :message => "wasn't provided"
  validates_uniqueness_of :user, :scope => :initiative, :message => "may only vote once"

  private

  def set_defaults
    self.decision ||= false
  end
end
