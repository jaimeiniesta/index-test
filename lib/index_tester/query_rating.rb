module IndexTester
  module QueryRating

    def query_rating(opts)
      return 100 if opts[:total_count] <= 1
      return 0 if opts[:no_indexes]
      ratio = opts[:scanned_count].to_f / opts[:total_count]
      scan_rating = ((ratio * -100) + 100) / 2
      return_rating = (50 * (opts[:returned_count].to_f / opts[:scanned_count]))
      scan_rating + return_rating 
    end
  end
end
