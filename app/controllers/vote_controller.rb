class VoteController < ApplicationController
  before_filter :authenticate_user!                                      # all voting activity requires a session (provided by Devise)
  before_filter :initiative_exists?                                      # all voting requires an initiative as the voting subject
  before_filter :attempt_to_get_vote                                     # a vote may or may not exist but all actions should check
  before_filter :has_not_voted?,     :only => [:new, :create]            # make sure people can only vote once
  before_filter :vote_exists?,       :only => [:show, :update, :destroy] # these methods require a valid vote

  # renders the page where a voter will decide what vote to cast
  def new
    @vote = @vote || Vote.new

    unless can? :create, @vote
      logger.info "unregistered visit to the voting page was redirected to registration"
      return redirect_to new_user_registration_path
    end

    @vote_contents = NCI::Views::Vote.to_hash(@vote)
  end

  # handles the submission of a casted vote by a voter
  def create
    # not sure under what conditions this would happen since we have before_filters
    # but we definitely want to be careful and conservative
    unless can? :create, @vote
      logger.info "user #{current_user.inspect} tried to cast a vote but was not authorized"
      return redirect_to new_user_registration_path
    end

    # FIXME: add journal documentation of this event
    unless @vote = current_user.votes.cast_vote_on_initiative(@initiative.id, params[:decision])
      logger.warn "user #{current_user.inspect} submitted a vote with invalid data #{@vote_contents.inspect}"
      flash[:warn] = "There was an issue with your vote."
      return render :new
    end

    @vote_contents = NCI::Views::Vote.to_hash(@vote)
  end

  # view a vote
  # NOTE: vote is automatically found via a before filter
  def show
    # FIXME: verify that can is properly checking ownership of the vote... magical
    unless user.can? :read, @vote
      logger.warn "user #{current_user.inspect} attempted to read vote #{params[:ref_code].inspect} but was not authorized to do so"
      unauthorized!
    end
  end

  # modify a vote
  # NOTE: vote is automatically found via a before filter
  def update
    # FIXME: verify that can is properly checking ownership of the vote... magical
    unless user.can? :update, @vote
      logger.warn "user #{current_user.inspect} attempted to update vote #{params[:ref_code].inspect} but was not authorized to do so"
      unauthorized!
    end

    # FIXME: add journal documentation of this event
    unless @vote.update_attributes!(@vote_contents)
      logger.warn "user #{current_user.inspect} attempted to update vote with invalid data #{@vote_contents.inspect}"
      return render :status => 422
    end

    @vote_contents = NCI::Views::Vote.to_hash(@vote)
  end

  # nuke a vote
  # NOTE: vote is automatically found via a before filter
  def destroy
    unless user.can? :destroy, @vote
      logger.warn "user #{current_user.inspect} attempted to destroy vote #{params[:ref_code].inspect} but was not authorized to do so"
      unauthorized!
    end

    # FIXME: add journal documentation of this event
    unless @vote.destroy
      logger.error "vote #{params[:ref_code].inspect} was unable to be destroyed"
      return render :status => 500 # something bizarre happened
    end
  end

  private

  def initiative_exists?
    unless @initiative = Initiative.where(:code => params[:initiative_code]).first
      logger.warn "vote requested on nonexistant initiative #{params[:initiative_code]}"
      return render :status => 404
    end

    @initiative_contents = NCI::Views::Initiative.to_hash(@initiative)
  end

  def attempt_to_get_vote
    @vote = current_user.read_vote_on_initiative(@initiative.id)
  end

  def vote_exists?
    unless @vote
      logger.warn "the vote cast by user #{current_user.inspect} for initiative #{initiative.id.inspect} was requested but not found"
      return render :status => 404
    end

    @vote_contents = NCI::Views::Vote.to_hash(@vote)
  end

  def has_not_voted?
    if @vote
      flash[:warn] = "You have already voted. Your vote is displayed below."
      return redirect_to show_vote_path(@vote.ref_code)
    end
  end
end
