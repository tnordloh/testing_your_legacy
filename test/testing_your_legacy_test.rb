
require 'minitest/autorun'
require_relative '../lib/testing_your_legacy/testing_your_legacy'

describe TestingYourLegacy do

  it "can create a log entry" do
    l = TestingYourLegacy::LogEntry.new("/","GET",5)
    l[:url].must_equal("/")
  end

  it "can create a log summary" do
    first= TestingYourLegacy::LogEntry.new("/","GET",5)
    second= TestingYourLegacy::LogEntry.new("/user","GET",4)
    values = [first, second]
    list = TestingYourLegacy::LogSummary.new(values)
    list.first["protocol"].must_equal("GET")
  end

  it "can return logs in the correct order" do
    first= TestingYourLegacy::LogEntry.new("/","GET",4)
    second= TestingYourLegacy::LogEntry.new("/user","GET",5)
    values = [first, second]
    list = TestingYourLegacy::LogSummary.new(values)
    list.first["visits"].must_equal(5)
  end

end
