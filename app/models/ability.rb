# defines the abilities of various roles in our application
class Ability
  include CanCan::Ability

  # See wiki for more info: https://github.com/ryanb/cancan/wiki/Defining-Abilitise
  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.role? :admin
      can :manage, :all
    elsif user.role? :voter
      can :create, Vote
    end

    # default is can't do anything special for now
  end
end
