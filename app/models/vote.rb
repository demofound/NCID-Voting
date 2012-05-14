class Vote < ActiveRecord::Base
  include NCI::Utils::RefCode

  belongs_to :registration
  belongs_to :initiative

  before_save :set_defaults

  validates_presence_of   :initiative,      :message => "wasn't provided"
  validates_uniqueness_of :registration_id, :scope   => :initiative_id, :message => "may only vote once"

  private

  has_paper_trail :skip => PAPER_TRAIL_SKIP_ATTRIBUTES

  def set_defaults
    self.decision ||= false
    self.ref_code ||= NCI::Utils::RefCode.generate(10)
  end
end
