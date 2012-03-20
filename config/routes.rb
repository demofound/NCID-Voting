# we're gonna override activeadmin's devise path but keep the normal path for everything else
# it'd be weird to present the general public with /admin URLs just for that
#  FIXME: there's probably a cleaner way to do this using the initializer but I don't
#  have the time to dig through it
active_admin_devise_config = ActiveAdmin::Devise.config.merge :path => "/user"

NciVote::Application.routes.draw do
  ActiveAdmin.routes(self)

  root :to => "home#index"
  get  "home/index"

  devise_for :users, active_admin_devise_config

  controller :user, :path => "/" do
    get  "user/choose_locale/registration" => :choose_location, :as => :choose_location_user
    get  "user/domestic/registration"      => :meta_domestic,   :as => :meta_domestic_user
    get  "user/international/registration" => :meta_foreign,    :as => :meta_foreign_user
    post "user/registration"               => :meta_do,         :as => :meta_do_user
  end

  controller :vote, :path => "/" do
    get    ":initiative_code/vote"  => :new,    :as => :new_vote
    post   ":initiative_code/vote"  => :create, :as => :create_vote
    get    "vote/:ref_code"         => :show,   :as => :show_vote
    put    "vote/:ref_code"         => :update, :as => :update_vote
    delete "vote/:ref_code"         => :delete, :as => :delete_vote
  end

  controller :info, :path => "/info" do
    get "/faq"       => :faq,       :as => :faq
    get "/full_text" => :full_text, :as => :full_text
  end
end
