require 'minitest/autorun'

require_relative '../lib/testing_your_legacy/raw_file.rb'
describe TestingYourLegacy::RawFile do

  def setup
    @reader = TestingYourLegacy::RawFile
                                     .new(File.open("./test/fixtures/mock.log"))
  end

  it "gets first url from a rails log" do
    first = @reader.parsed_urls.first
    first[:url].must_equal("/")
    first[:protocol].must_equal("GET")
  end

  it "gets can count the visits to a url" do
    url_pattern = ["/", "GET" ]
    @reader.sum[ url_pattern ].must_equal(581)
  end

  it "sanitizes urls with ids" do
    @reader.int_to_id("/one/1/55").must_equal("/one/id/id")
  end

end


