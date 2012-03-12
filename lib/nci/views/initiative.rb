module NCI
  module Views
    class Initiative
      # pass in an activerecord initiative object
      def self.to_hash(initiative, *args)
        return {
          :name => initiative.name,
          :code => initiative.code
        }
      end
    end
  end
end
