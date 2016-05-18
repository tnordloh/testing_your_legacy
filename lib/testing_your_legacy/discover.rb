require_relative './testing_your_legacy'

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
      "test \"visit #{record[:url]}\" do\n" +
      "  #this url was visited #{record[:visits]} times\n" +
      "  #{record[:protocol].downcase} #{record[:url]}\n"  +
      "  assert_response :success\n" +
      "end\n" 
    end

    def generate_test(record)
      "def \"#{record[:url].gsub("/","_")}\"\n" +
      "  #this url was visited #{record[:visits]} times\n" +
      "  #{record[:protocol].downcase} #{record[:url]}\n"  +
      "  assert_response :success\n" +
      "end\n"
    end

  end
end
