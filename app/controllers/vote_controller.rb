class VoteController < ApplicationController
  before_filter :authenticate_user!                                      # all voting activity requires a session (provided by Devise)
  before_filter :certified?,         :only => [:new, :create]            # all voting requires a certified registration
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
    unless @vote = current_user.current_registration.cast_vote_on_initiative(@initiative.code, params[:decision])
      logger.warn "user #{current_user.inspect} submitted a vote with invalid data #{@vote_contents.inspect}"
      flash[:warn] = "There was an issue with your vote."
      return render :new
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
  #     logger.warn "user #{current_user.inspect} attempted to update vote with invalid data #{@vote_contents.inspect}"
  #     return render :status => 422
  #   end

  #   @vote_contents = NCI::Views::Vote.to_hash(@vote)
  # end

  # nuke a vote disabled - probably don't want this
  # NOTE: vote is automatically found via a before filter
  # def destroy
  #   authorize! :destroy, @vote

  #   # FIXME: add journal documentation of this event
  #   unless @vote.destroy
  #     logger.error "vote #{params[:ref_code].inspect} was unable to be destroyed"
  #     return render :status => 500 # something bizarre happened
  #   end
  # end

  private

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

    if @initiative && @registration = current_user.current_registration
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

  def certified?
    # NOTE: registration requirement handled by "redirect_if_user_registration_needed"
    #       before_filter in application controller
    # not using roles here before the registrations can change out from underneath us
    unless current_user.can_vote?
      flash[:info] = "We have your voter registration on file but it must be certified by a certifier before you are eligble to vote."
      logger.info "uncertified visit to the voting page was redirected to registration"
      return redirect_to root_path
    end
  end

  def has_not_voted?
    if @vote
      flash[:warn] = "You have already voted. Your vote is displayed below."
      return redirect_to show_vote_path(@vote.ref_code)
    end
  end
end
