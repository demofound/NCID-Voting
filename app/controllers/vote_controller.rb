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
    vote_contents = {
      # TODO: define some contents
    }

    unless @vote = Vote.create(vote_contents)
      logger.warn "user #{current_user.inspect} submitted a vote with invalid data #{vote_contents.inspect}"
      return render :status => 422
    end

    unauthorized! if cannot? :create, @vote
  end

  # view a vote
  def show
    # FIXME: verify that can is properly checking ownership of the vote... magical
    unless user.can? :read, @vote
      logger.warn "user #{current_user.inspect} attempted to read vote #{params[:ref_code].inspect} but was not authorized to do so"
      unauthorized!
    end
  end

  # modify a vote
  def update
    # FIXME: verify that can is properly checking ownership of the vote... magical
    unless user.can? :update, @vote
      logger.warn "user #{current_user.inspect} attempted to delete vote #{params[:ref_code].inspect} but was not authorized to do so"
      unauthorized!
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
