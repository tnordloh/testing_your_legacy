module TestingYourLegacy

  require_relative 'testing_your_legacy'
  class RawFile

    def initialize(file,count = 25)
      @file  = file
      @count = count
    end

    def each
      to_log_summary.each { |record| yield record }
    end

    def to_log_summary
      TestingYourLegacy::LogSummary.new(to_a)
    end

    def to_a
      sum.keys.each_with_object([]) do | key, memo | 
        memo << TestingYourLegacy::LogEntry.new(key[0],
                                                key[1],
                                                sum[key])
      end
    end

    def sum
      @sum ||= parsed_urls.each_with_object(Hash.new(0)) do |url,memo|
        memo[[int_to_id(url[:url]),url[:protocol]]] += 1
      end
    end

    def int_to_id(url)
      url.gsub(/\d+/,"id").gsub(/\?.*/,"?search_string")
    end

    def parsed_urls
      @parsed_urls ||= started_only.map do |line|
        line.match(/^Started (?<protocol>\w+) "(?<url>.*)"/)
      end
    end

    def started_only
      @started_only ||= @file.select { |line| 
        line.match(/^Started/) && !line.match(/assets/)
      }
    end

  end
end
