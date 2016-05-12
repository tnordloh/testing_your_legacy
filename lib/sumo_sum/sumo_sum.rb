require 'Sumo'
require 'Time'

require_relative './constants'
require_relative '../../lib/discover'

module SumoSum
  class SumoSum

    def top_visits
      @top_visits ||= get_records
    end

    def get_records
      query = Sumo.search(query: TOP_CLASSES,
                      from: '2016-01-01T00:00:00',
                      to: "#{Time.now.utc.iso8601.chop}",
                      time_zone: 'UTC'
                     )
      until query.status['state'] == "DONE GATHERING RESULTS" do
        p "gathering results -- sleeping 2 seconds:records so far: #{query.status["recordCount"]}"
        sleep 2
      end
      query.records
    end

    def each
      top_visits
      @top_visits.each do |record| 
        yield StartingPoint::LogEntry.new(get_link(record), "POST", record[:visits] )  
      end 
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

