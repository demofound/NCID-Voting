# defines the abilities of various roles in our application
class Ability
  include CanCan::Ability

  # See wiki for more info: https://github.com/ryanb/cancan/wiki/Defining-Abilitise
  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.role? :admin
      can :manage, :all
    else
      # the typical read :all won't work here. will have to think about proper permissions on vote reading
    end
  end
end
