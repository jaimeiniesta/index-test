require 'active_record'

module IndexTester
  class DataBase
    #mixes orm and db logic
    #needs to have component for db
    def initialize
      establish_connection
    end

    def establish_connection
      ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3',
        :database => '../../db/test')
    end

    def execute(sql)
      ActiveRecord::Base.connection.execute(sql)
    end

    #methods below should belong to db, not orm
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
