# we're gonna override activeadmin's devise path but keep the normal path for everything else
# it'd be weird to present the general public with /admin URLs just for that
#  FIXME: there's probably a cleaner way to do this using the initializer but I don't
#  have the time to dig through it
active_admin_devise_config = ActiveAdmin::Devise.config.merge :path => "/user"

NciVote::Application.routes.draw do
  ActiveAdmin.routes(self)

  root :to => "home#index"
  get  "home/index"

  # this macro handles account registration...
  devise_for :users, active_admin_devise_config

  controller :user, :path => "/user" do
    get "account" => :update,    :as => :update_user
    put "account" => :update_do, :as => :update_user_do
  end

  # this 'registration' means *voter registration* not account registration. sorry for any confusion
  # but I felt any other word would just make things more confusing and didn't wanna override Devises' concepts
  controller :registration, :path => "/" do
    get  "register_to_vote/choose_locale" => :choose_location,     :as => :choose_location
    get  "register_to_vote/information"   => :register,            :as => :register
    post "register_to_vote"               => :register_do,         :as => :register_do
  end

  controller :vote, :path => "/" do
    get    ":initiative_code/vote"  => :new,    :as => :new_vote
    post   ":initiative_code/vote"  => :create, :as => :create_vote

    get    "vote/:ref_code"         => :show,   :as => :show_vote
# modify vote disabled - probably don't want it
#    put    "vote/:ref_code"         => :update, :as => :update_vote
# delete vote disabled - probably don't want it
#    delete "vote/:ref_code"         => :delete, :as => :delete_vote
  end

  controller :info, :path => "/info" do
    get "/faq"       => :faq,       :as => :faq
    get "/full_text" => :full_text, :as => :full_text
  end
end
