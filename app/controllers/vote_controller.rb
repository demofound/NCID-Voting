class VoteController < ApplicationController
  before_filter :get_user!                                               # all voting activity requires a session (provided by Devise)
  # it was requested NCID staff that users be able to vote without a registration
  # before_filter :certified?,         :only => [:new, :create]            # all voting requires a certified registration
  before_filter :initiative_exists?, :only => [:new, :create]            # voting requires an initiative as the voting subject
  before_filter :attempt_to_get_vote                                     # a vote may or may not exist but all actions should check
  before_filter :has_not_voted?,     :only => [:new, :create]            # make sure people can only vote once
  before_filter :vote_exists?,       :only => [:show, :update, :destroy] # these methods require a valid vote

  # renders the page where a voter will decide what vote to cast
  def new
    @vote = @vote || Vote.new
    @vote_contents = NCI::Views::Vote.to_hash(@vote)
  end

  # handles the submission of a cast vote by a voter
  def create
    user = current_or_guest_user

    @vote = user.is_guest? ? user.cast_guest_vote_on_initiative(@initiative.code) :
      user.current_registration.cast_vote_on_initiative(@initiative.code)

    unless @vote
      logger.warn "user #{current_user_or_guest_user.inspect} submitted a vote with invalid data #{@vote_contents.inspect}"
      flash[:warn] = "There was an issue with your vote."
      return render :new
    end

    if current_or_guest_user.is_guest?
      flash[:info] = "We have documented your vote. Next you must create an account with us for the vote to be tabulated."
      return redirect_to new_user_session_path
    end

    @vote_contents = NCI::Views::Vote.to_hash(@vote)
  end

  # view a vote
  # NOTE: vote is automatically found via a before filter
  def show
    authorize! :read, @vote
  end

  # modify a vote disabled - probably don't need or want this
  # NOTE: vote is automatically found via a before filter
  # def update
  #   # FIXME: verify that can is properly checking ownership of the vote... magical
  #   authorize! :update, @vote

  #   unless @vote.update_attributes!(@vote_contents)
  #     logger.warn "user #{current_or_guest_user.inspect} attempted to update vote with invalid data #{@vote_contents.inspect}"
  #     return render :status => 422
  #   end

  #   @vote_contents = NCI::Views::Vote.to_hash(@vote)
  # end

  # nuke a vote disabled - probably don't want this
  # NOTE: vote is automatically found via a before filter
  # def destroy
  #   authorize! :destroy, @vote

  #   unless @vote.destroy
  #     logger.error "vote #{params[:ref_code].inspect} was unable to be destroyed"
  #     return render :status => 500 # something bizarre happened
  #   end
  # end

  private

  def get_user!
    # either get the current logged-in user or create a guest user
    current_or_guest_user
  end

  def initiative_exists?
    unless @initiative = Initiative.where(:code => params[:initiative_code]).first
      logger.warn "vote requested on nonexistant initiative #{params[:initiative_code]}"
      return render :status => 404
    end

    @initiative_contents = NCI::Views::Initiative.to_hash(@initiative)
  end

  def attempt_to_get_vote
    if params[:ref_code]
      return @vote = Vote.first(:conditions => {:ref_code => params[:ref_code]})
    end

    if @initiative && @registration = current_or_guest_user.current_registration
      @vote = @registration.read_vote_on_initiative(@initiative.code)
    end
  end

  def vote_exists?
    unless @vote
      logger.warn "the vote cast by registration #{@registration.inspect} for initiative #{@initiative.inspect} was requested but not found"
      return render :status => 404
    end

    @vote_contents = NCI::Views::Vote.to_hash(@vote)
  end

  # it was requested NCID staff that users be able to vote without a registration
  # def certified?
  #   # NOTE: registration requirement handled by "redirect_if_user_registration_needed"
  #   #       before_filter in application controller
  #   # not using roles here before the registrations can change out from underneath us
  #   unless current_or_guest_user.can_vote?
  #     flash[:info] = "You must be registered before you are eligible to vote."
  #     logger.info "unregistered visit to the voting page was redirected to registration"
  #     return redirect_to root_path
  #   end
  # end

  def has_not_voted?
    if @vote
      flash[:warn] = "You have already voted. Your vote is displayed below."
      return redirect_to show_vote_path(@vote.ref_code)
    end
  end
end
