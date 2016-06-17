require 'minitest/autorun'

require_relative "../lib/testing_your_legacy/discover"

describe TestingYourLegacy::Discover do

  it "can get local repository status" do
    one = {protocol: 'POST',
           url: 'link/to',
           visits: 6}
    two = {protocol: 'GET',
           url: 'link/two',
           visits: 5}
    log_stub = [ one, two]
    logs = TestingYourLegacy::Discover.new(log_stub)
    logs.each { |line|
      line[:protocol].class.must_equal(String)
    }
  end

  it "can print a test from the template" do
    logs = TestingYourLegacy::Discover.new(nil)
    one = {protocol: 'POST',
           url: 'link/to',
           visits: 6}
    logs.generate_test(one).class.must_equal(String)
  end

  it "can print a method from the template" do
    logs = TestingYourLegacy::Discover.new(nil)
    one = {protocol: 'POST',
           url: 'link/to',
           visits: 6}
    logs.generate_method(one).class.must_equal(String)
  end

end

