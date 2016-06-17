require_relative "testing_your_legacy/discover"
require_relative "sumo_sum/sumo_sum"

module SumoSum
  def self.process(source_category,count)
    list = SumoSum.new(source_category,count)
    discovers = TestingYourLegacy::Discover.new(list)

    discovers.each do |r|
      puts discovers.generate_test(r) + "\n"
    end
  end

  def self.process_file(file,count)
    list=TestingYourLegacy::RawFile.new(file,count)
    discovers = TestingYourLegacy::Discover.new(list)

    discovers.each do |r|
      puts discovers.generate_test(r) + "\n"
    end

  end
end
