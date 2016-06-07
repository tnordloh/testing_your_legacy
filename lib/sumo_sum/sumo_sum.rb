require 'Sumo'
require 'Time'

require_relative './constants'
require_relative '../../lib/testing_your_legacy/testing_your_legacy'
require_relative '../../lib/testing_your_legacy/discover'

module SumoSum
  class SumoSum

    def initialize(source_category= "*",count=25)
      @source_category = source_category
      @count           = count
    end

    attr_reader :source_category, :count

    def sum_with_source
      "_sourceCategory=" + source_category + " " + TOP_CLASSES
    end

    def top_visits
      @top_visits ||= get_records
    end

    def get_records()
      query = Sumo.search(query:  sum_with_source,
                           from: "#{days_ago}",
                             to: "#{Time.now.utc.iso8601.chop}",
                      time_zone: 'UTC'
                     )

      until query.status['state'] == "DONE GATHERING RESULTS" do
        STDERR.puts "gathering results -- sleeping 2 seconds:records so far: #{query.status["recordCount"]}"
        sleep 2
      end
      query.records
    end

    def each
      p top_visits.methods
      p top_visits.class
      top_visits.first(count).each do |record| 
        yield TestingYourLegacy::LogEntry.new(get_link(record),        #comment
                                              record["protocol"],      #comment
                                              record["_approxcount"])  #comment
      end 
    end

    def days_ago(days=90)
      ninety_days_ago_in_seconds=60*60*24*days
      (Time.now - ninety_days_ago_in_seconds).utc.iso8601.chop
    end

    def get_link(record)
      "/" + 
        ["class","method"].map do |field| 
        record[field]
        end
      .reject {|field|
        field==""
      }
      .join("/")
      #record['class'] + "::" + record["method"]
    end
  end
end

