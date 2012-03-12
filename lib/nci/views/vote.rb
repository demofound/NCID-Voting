module NCI
  module Views
    class Vote
      # pass in an activerecord initiative object
      def self.to_hash(vote, *args)
        hash = {
          :decision => vote.decision,
          :ref_code => vote.ref_code
        }

        if args.include? :user
          hash.merge! :user => NCI::Views::User.to_hash(vote.user)
        end

        return hash
      end
    end
  end
end

