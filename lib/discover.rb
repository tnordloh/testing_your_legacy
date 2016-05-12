require_relative './testing_your_legacy'

module TestingYourLegacy
  class Discover
    def initialize(logs)
      @logs=logs
    end

    def each
      @logs.each do |record| 
        puts generate_test(record)
        yield record
      end 
    end

    def generate_test(record)
      "test \"visit #{record[:url]}\" do\n" +
      "  #{record[:method].downcase} #{record[:url]}\n"  +
      "  assert_response :success\n" +
      "end"
    end

  end
end
