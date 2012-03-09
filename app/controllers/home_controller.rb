class HomeController < ApplicationController
  def index
    @testimonials = Testimonial.recent_featured.map{|t| NCI::Views::Testimonial.to_hash(t)}
  end
end
