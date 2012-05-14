class UserController < ApplicationController
  before_filter :get_user
  before_fitler :session_required

  def update

  end

  def update_do
  end

  protected

  def get_user
    @user = current_user
  end
end
