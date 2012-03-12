require 'digest/sha1'

module NCI
  module Utils
    module RefCode
      def self.generate(size)
        return Digest::SHA1.hexdigest(rand.to_s).to_i(16).to_s(36)[0..size-1]
      end
    end
  end
end
