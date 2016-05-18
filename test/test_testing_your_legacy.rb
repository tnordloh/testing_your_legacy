require 'minitest/autorun'

require_relative "../lib/testing_your_legacy/discover"

describe TestingYourLegacy::Discover do

  it "can get local repository status" do
    one = {method: 'POST',
           link: 'link/to',
           visits: 6}
    two = {method: 'GET',
           link: 'link/two',
           visits: 5}
    log_stub = [ one, two]
    logs = TestingYourLegacy::Discover.new(log_stub)
    #logs.top_links.class.must_equal(Sumo::Search)
    logs.each { |line|
      p line
    } 
   # puts logs.top_visits.first
  end

end

