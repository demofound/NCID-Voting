class Vote < ActiveRecord::Base
  include NCI::Utils::RefCode

  belongs_to :user
  belongs_to :initiative

  before_save :set_defaults

  validates_presence_of      :initiative,                     :message => "wasn't provided"
  validates_uniqueness_of :user_id, :scope => :initiative_id, :message => "may only vote once"

  private

  has_paper_trail

  def set_defaults
    self.decision ||= false
    self.ref_code ||= NCI::Utils::RefCode.generate(10)
  end
end
