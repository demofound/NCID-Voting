module NCI
  module Views
    class Testimonial
      # pass in an activerecord testimonial object and optionally a user as well,
      # if you have it already and want to save the extra DB hit to get the user
      #  optionally include a series of testimonial aspects to include in the hash as *args
      #  eg: NCI::Views::Testimonial.to_hash(some_testimonial, :metadata) and the testimonials's
      #      metadata will me merged passed back in the returned hash
      def self.to_hash(testimonial, user = testimonial.user, *args)

        # this is the stuff we always want to return
        hash = {
          :user => NCI::Views::User.to_hash(user),
          :body => response.body
        }

        # optional hash additions

        # this stuff is mostly useful for administrative purposes
        if args.include? :metadata
          hash.merge :metadata => {
            :created_at  => testimonial.created_at,
            :modified_at => testimonial.modified_at,
            :state       => testimonial.state
          }
        end
      end
    end
  end
end
