NciVote::Application.routes.draw do
  ActiveAdmin.routes(self)

  root :to => "home#index"
  get  "home/index"

  devise_for :users, ActiveAdmin::Devise.config

  controller :vote, :path => "/" do
    get    ":initiative_code/vote"  => :new,    :as => :new_vote
    post   ":initiative_code/vote"  => :create, :as => :create_vote
    get    "vote/:ref_code"         => :show,   :as => :show_vote
    put    "vote/:ref_code"         => :update, :as => :update_vote
    delete "vote/:ref_code"         => :delete, :as => :delete_vote
  end
end
