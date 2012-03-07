NciVote::Application.routes.draw do
  ActiveAdmin.routes(self)

  root :to => "home#index"
  get "home/index"

  devise_for :users, ActiveAdmin::Devise.config

  controller :vote, :path => "/vote" do
    get    "/cast"      => :new,    :as => :new_vote
    post   "/cast"      => :create, :as => :create_vote
    get    "/:ref_code" => :show,   :as => :show_vote
    put    "/:ref_code" => :update, :as => :update_vote
    delete "/:ref_code" => :delete, :as => :delete_vote
  end
end
