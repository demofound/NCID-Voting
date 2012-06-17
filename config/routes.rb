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
  devise_for :users, active_admin_devise_config.merge(:controllers => { :registrations => "users/registrations" })

  controller :user, :path => "/user" do
    get "account" => :edit,   :as => :edit_user
    put "account" => :update, :as => :update_user
  end

  # this 'registration' means *voter registration* not account registration. sorry for any confusion
  # but I felt any other word would just make things more confusing and didn't wanna override Devises' concepts
  controller :registration, :path => "/" do
    get  "register_to_vote" => :new,    :as => :new_registration
    put  "register_to_vote" => :update, :as => :update_registration
    post "register_to_vote" => :create, :as => :create_registration
  end

  controller :vote, :path => "/" do
    get    ":initiative_code/vote"  => :new,    :as => :new_vote
    post   ":initiative_code/vote"  => :create, :as => :create_vote
    get    "vote/:ref_code"         => :show,   :as => :show_vote
  end

  controller :info, :path => "/info" do
    get "/faq"       => :faq,       :as => :faq
    get "/full_text" => :full_text, :as => :full_text
  end
end
