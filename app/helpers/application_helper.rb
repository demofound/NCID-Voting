module ApplicationHelper
  include NCI::Views

  def current_org
    # can always override this later if we do something fancier
    return "Philadelphia II"
  end
end
