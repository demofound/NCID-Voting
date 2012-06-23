class VoteController < ApplicationController
  before_filter :get_user!                                               # all voting activity requires a session (provided by Devise)
  before_filter :has_not_voted?,     :only => [:new, :create]            # make sure people can only vote once
  before_filter :has_registration?                                       # current behavior is that one needs a registration to vote
                                                                         # NOTE: the registration may be owned by a guest, however

  before_filter :initiative_exists?, :only => [:new, :create]            # voting requires an initiative as the voting subject
  before_filter :attempt_to_get_vote                                     # a vote may or may not exist but all actions should check
  before_filter :vote_exists?,       :only => [:show, :update, :destroy] # these methods require a valid vote

  # renders the page where a voter will decide what vote to cast
  def new
    @vote = @vote || Vote.new
    @vote_contents = NCI::Views::Vote.to_hash(@vote)
  end

  # handles the submission of a cast vote by a voter
  def create
    user = current_user

    @vote = user.current_registration.cast_vote_on_initiative(@initiative.code)

    unless @vote
      logger.warn "user #{current_user.inspect} submitted a vote with invalid data #{@vote_contents.inspect}"
      flash[:warn] = "There was an issue with your vote."
      return render :new
    end

    @vote_contents = NCI::Views::Vote.to_hash(@vote)

    flash[:info] = "We have successfully recorded your vote."
  end

  private

  def get_user!
    current_user
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

  def has_registration?
    unless current_user
      return redirect_to new_user_registration_path(:forward_url => url_for(params))
    end
  end

  def has_not_voted?
    if @vote
      flash[:warn] = "You have already voted."
      redirect_to return_to_storage
    end
  end
end
