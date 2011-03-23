require 'mustache'

module IndexTester
  class GenerateTests

    def initialize(harvester)
      @harvester = harvester
    end

    def test_code
      opts = []
      @harvester.queries.each_index do |index|
        opts << {total_count:    @harvester.record_counts[@harvester.tables[index]],
                 no_indexes:     @harvester.missing_indexes[index],
                 scanned_count:  @harvester.scanned_counts[index],
                 returned_count: @harvester.returned_counts[index],
                 query:          @harvester.queries[index]}
      end
      result = TestsView.new(opts).render
    end
  end

  class TestsView < Mustache
    self.template_file = File.dirname(__FILE__) + '/template/tests_view.mustache'

    def initialize(params)
      @params = params
    end

    def looper
      @params.each
    end
  end
end
