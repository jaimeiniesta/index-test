require 'csv'

module IndexTester
  class ReadLog
    def initialize(file_name)
      @file_name = file_name
      @content = read
    end
    def read
      CSV.read(@file_name)
    end
    def query
      @content.transpose[0]
    end
    def stack_trace
      @content.transpose[1]
    end
    def timestamp
      @content.transpose[2]
    end
  end
end
