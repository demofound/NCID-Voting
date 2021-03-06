module NCI
  module Views
    class Initiative
      # pass in an activerecord initiative object
      def self.to_hash(initiative, *args)
        return {
          :id          => initiative.id,
          :name        => initiative.name,
          :description => initiative.description,
          :code        => initiative.code
        }
      end
    end
  end
end
