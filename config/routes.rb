NciVote::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :users, ActiveAdmin::Devise.config

  root :to => "home#index"
  get "home/index"

  controller :vote, :path => "/vote" do
    get  "/cast" => :new,    :as => :new_vote
    post "/cast" => :create, :as => :create_vote
  end
end
