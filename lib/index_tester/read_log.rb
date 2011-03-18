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
      get_explains.map {|exp| @db.table_of_explain(exp)}
    end

    def record_counts
      tables.uniq.inject({}) {|counts, table| counts[table] = @db.execute_count(table); counts}
    end

    def get_explains
      @explains ||= @queries.inject([]) {|result,q| result << @db.execute_explain(q); result}
    end    
    
    def missing_indexes
      get_explains.map {|exp| @db.index_of_explain(exp).nil?}
    end

    def scanned_counts
      get_explains.map {|exp| @db.scanned_counts_of_explain(exp)}
      [2,2,1]
    end

    def returned_counts
      @queries.map {|query| @db.execute(query).size}
    end

    def rating(query_index)
      return 100 if record_counts[tables[query_index]] <= 1
      return 0 if missing_indexes[query_index]
      ratio = scanned_counts[query_index].to_f / record_counts[tables[query_index]]
      part1 = ((ratio * -100) + 100) / 2
      part1 + (50 * (returned_counts[query_index].to_f / scanned_counts[query_index]))
    end
  end
  class DataBase
    def initialize
      ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3',
        :database => '../../db/test')
    end

    def execute(sql)
      ActiveRecord::Base.connection.execute(sql)
    end

    def execute_count(table)
      execute("select count(*) from #{table};")[0][0]
    end

    def execute_explain(query)
      execute("explain query plan #{query}")[0]['detail']
    end

    def table_of_explain(explanation)
      explanation.match(/^TABLE (\w+)/)[1]
    end

    def index_of_explain(explanation)
      explanation.match(/INDEX/)
    end

    def scanned_counts_of_explain(explanation)
      match_data = explanation.match(/\~(\d+) rows/) ? match_data[0] : 0
    end
  end
end
