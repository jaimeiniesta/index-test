module IndexTester
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
end
