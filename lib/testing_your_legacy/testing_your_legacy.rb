module TestingYourLegacy
  LogEntry=Struct.new(:url,:protocol,:visits) {

    include Comparable

    def <=>(other)
      visits <=> other.visits
    end

  }

  LogSummary=Struct.new(:list) {

    def each 
      list.sort.reverse.each do |entry|
        yield entry
      end
    end

  }
end
