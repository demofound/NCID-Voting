module NCI
  module Views
    class User
      # pass in an activerecord user object and get a 'view safe' hash
      #  optionally include a series of user aspects to include in the hash as *args
      #  eg: NCI::Views::User.to_hash(some_user, :testimonials) and the user's testimonials
      #      will me merged passed back in the returned hash
      def self.to_hash(user, *args)
        registration = user.current_registration

        # this is the base hash that we will always return
        hash = {
          :username => user.username,
          :fullname => registration.fullname,
          :avatar   => user.avatar.url
        }

        # optional hash additions

        if args.include? :testimonials
          hash.merge! :testimonials => user.testimonials.map{ |t| NCI::Views::Testimonial.to_hash(t, user) }
        end

        if args.include? :state
          hash.merge :state => registration.state
        end

        return hash
      end
    end
  end
end
