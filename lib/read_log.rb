require 'csv'
require 'active_record'

module IndexTester
  class ReadLog
    def initialize(file_name)
      @file_name = file_name
      @content = load_csv
    end
    def load_csv
      CSV.read(@file_name)
    end
    def unique_log_entries
      @content.inject({}) {|list, line| list[line[1]] = line; list}.values
    end
    def unique_selects
      unique_log_entries.inject([]) {|list, entry| list << entry[0]; list}
    end
  end
  class HarvestData
    def initialize(db, queries)
      @db, @queries = db, queries
    end

    def tables
      ['orders']
      get_explains.map {|exp| exp.match(/^TABLE (\w+)/)[1]}.uniq
    end

    def get_record_counts
      tables.inject({}) {|counts, table| counts[table] = @db.execute_count(table); counts}
    end

    def get_explains
      @explains ||= @queries.inject([]) {|result,q| result << @db.execute_explain(q); result}
    end    
    
    def missing_indexes
      get_explains.map {|exp| exp.match(/INDEX/).nil?}
    end
    def scanned_counts
      get_explains.map {|exp| md = exp.match(/\~(\d+) rows/) ? md[0] : 0}
    end
  end
  class DataBase
    def initialize
      ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3',
        :database => '../db/test')
    end
    def connection
      ActiveRecord::Base.connection
    end
    def execute_count(table)
      connection.execute("select count(*) from #{table};")[0][0]
    end
    def execute_explain(query)
      connection.execute("explain query plan #{query}")[0]['detail']
    end
  end
end
