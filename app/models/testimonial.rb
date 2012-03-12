class Testimonial < ActiveRecord::Base
  belongs_to :user

  enum_attr :state, %w(unapproved approved featured)

  before_save :set_defaults

  def self.recent_featured(count = 3)
    return self.where(:state => :featured).order("created_at DESC").limit(count)
  end

  has_paper_trail :skip => PAPER_TRAIL_SKIP_ATTRIBUTES

  private

  def set_defaults
    self.state ||= :unapproved
  end
end
