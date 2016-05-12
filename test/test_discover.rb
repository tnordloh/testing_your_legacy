require 'minitest/autorun'

require_relative "../lib/discover"

describe StartingPoint::Discover do

  it "can get local repository status" do
    one = {method: 'POST',
           link: 'link/to',
           visits: 6}
    two = {method: 'GET',
           link: 'link/two',
           visits: 5}
    log_stub = [ one, two]
    logs = StartingPoint::Discover.new(log_stub)
    #logs.top_links.class.must_equal(Sumo::Search)
    logs.each { |line|
      p line
    } 
   # puts logs.top_visits.first
  end

end

