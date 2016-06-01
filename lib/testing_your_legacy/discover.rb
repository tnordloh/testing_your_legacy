require_relative './testing_your_legacy'
require 'erb'

module TestingYourLegacy
  class Discover
    def initialize(logs)
      @logs=logs
    end

    def each
      @logs.each do |record| 
        yield record
      end 
    end

    def generate_method(record)
      @record = record
      ERB.new(read_template('method_template.erb'))
         .result(binding())
    end

    def generate_test(record)
      @record = record
      ERB.new(read_template('test_template.erb'))
         .result(binding())
    end

    def read_template(template)
      File.read(File.join(File.dirname(__FILE__), template))
    end

  end
end
