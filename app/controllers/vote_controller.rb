class VoteController < ApplicationController
  before_filter :vote_exists?, :only => [:show, :update, :delete]

  # renders the page where a voter will decide what vote to cast
  def new
    @vote = Vote.new

    @vote_contents = {
      # TODO: define some contents
    }

    unauthorized! if cannot? :create, @vote
  end

  # handles the submission of a casted vote by a voter
  def create
    @vote_contents = {
      # TODO: define some contents
    }

    unless @vote = Vote.create(@vote_contents)
      logger.warn "user #{current_user.inspect} submitted a vote with invalid data #{@vote_contents.inspect}"
      return render :status => 422
    end

    unauthorized! if cannot? :create, @vote

    # FIXME: add journal documentation of this event
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
end
