class VoteController < ApplicationController
  before_filter :login_required?
  before_filter :vote_exists?,   :only => [:show, :update, :delete]
  before_filter :already_voted?, :only => [:new, :create]

  # renders the page where a voter will decide what vote to cast
  def new
    @vote = Vote.new

    @vote_contents = {
      # TODO: define some contents
    }

    unless can? :create, @vote
      logger.info "unregistered visiter voting page redirected to registration"
      return redirect_to new_user_registration_path
    end
  end

  # handles the submission of a casted vote by a voter
  def create
    @vote_contents = {
      # TODO: define some contents
    }

    # not sure under what conditions this would happen since we have before_filters
    # but we definitely want to be careful and conservative
    unless can? :create, @vote
      logger.info "user #{current_user.inspect} tried to cast a vote but was not authorized"
      return :status => 403
    end

    # FIXME: add journal documentation of this event
    unless @vote = Vote.create(@vote_contents)
      logger.warn "user #{current_user.inspect} submitted a vote with invalid data #{@vote_contents.inspect}"
      flash[:warn] = "There was an issue with your vote."
      return render
    end
  end

  # view a vote
  def show
    # FIXME: verify that can is properly checking ownership of the vote... magical
    unless user.can? :read, @vote
      logger.warn "user #{current_user.inspect} attempted to read vote #{params[:ref_code].inspect} but was not authorized to do so"
      unauthorized!
    end

    @vote_contents = {
      # TODO: define some contents
    }
  end

  # modify a vote
  def update
    # FIXME: verify that can is properly checking ownership of the vote... magical
    unless user.can? :update, @vote
      logger.warn "user #{current_user.inspect} attempted to update vote #{params[:ref_code].inspect} but was not authorized to do so"
      unauthorized!
    end

    @vote_contents = {
      # TODO: define some contents
    }

    # FIXME: add journal documentation of this event
    unless @vote.update_attributes!(@vote_contents)
      logger.warn "user #{current_user.inspect} attempted to update vote with invalid data #{@vote_contents.inspect}"
      return render :status => 422
    end
  end

  # nuke a vote
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

  def vote_exists?
    unless @vote = Vote.first(:conditions => {:ref_code => params[:ref_code]})
      logger.warn "vote #{params[:ref_code].inspect} requested but was not found"
      return render :status => 404
    end
  end

  def already_voted?
    if vote = current_user.vote
      flash[:warn] = "You have already voted. Your vote is displayed below."
      return redirect_to show_vote_path(vote.ref_code)
    end
  end
end
