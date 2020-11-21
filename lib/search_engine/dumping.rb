module SearchEngine
  module Dumping
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    class DumpException < RuntimeError; end

    module ClassMethods
      attr_reader :search_index_state

      def dump_index_to_file
        path = index_configuration.dump_dir_path
        filename = index_configuration.dump_filename

        FileUtils.mkdir_p(path) unless File.exist? path

        File.open("#{path}/#{filename}", 'w') do |file|
          file.write(@search_index.to_json)
        end
      end

      def load_index_from_file
        path = index_configuration.dump_dir_path
        filename = index_configuration.dump_filename

        File.open("#{path}/#{filename}", 'r') do |file|
          search_index.load_json(file.read)
        end
      end

      def initialize_dump_counter
        @search_index_state[:dump_counter] = 0
      end

      def increase_dump_counter
        @search_index_state[:dump_counter] += 1
      end

      def need_dump?
        raise DumpException, "Index doesn't exist" if @search_index.nil?

        @search_index_state[:dump_counter] >= index_configuration.dump_frequency && index_configuration.dump_enable
      rescue StandardError => e
        e.message
      end
    end
  end
end