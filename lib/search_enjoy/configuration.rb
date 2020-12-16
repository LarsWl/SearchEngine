module SearchEnjoy
  module Configuration
    def self.included(base)
      base.class_eval do
        @@index_configuration = Configuration.new(base)

        def self.index_configuration(&block)
          return @@index_configuration unless block_given?

          yield @@index_configuration
        end
      end
    end

    class Configuration
      attr_accessor :dump_dir_path, :dump_frequency, :dump_enable, :dump_filename

      def initialize(indexing_class)
        @dump_dir_path = "./data/search_enjoy"
        @dump_filename = "#{indexing_class}_#{Time.now.strftime('%Y%m%d%H%M%S')}"
        @dump_frequency = 100
        @dump_enable = true
      end
    end
  end
end