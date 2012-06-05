class Vote < ActiveRecord::Base
  include NCI::Utils::RefCode

  has_one :temp_vote_map
  belongs_to :registration
  belongs_to :initiative

  # it's a bad idea to access votes from the user because, really, registrations have votes.
  # the user relationship is mostly used for tallying unique votes by user for initiatives since
  # users can have many registrations and it would be difficult to tally without the user_id
  belongs_to :user

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
