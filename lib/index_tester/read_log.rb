require 'csv'

module IndexTester
  class ReadLog
    def initialize(file_name)
      @file_name = file_name
    end

    def unique_log_entries
      content.inject({}) {|list, line| list[line[1]] = line; list}.values
    end

    def unique_selects
      unique_log_entries.inject([]) {|list, entry| list << entry[0]; list}
    end

    private

    def content
      @content ||= CSV.read(@file_name)
    end
  end
end
