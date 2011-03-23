require_relative '../../lib/index_tester/read_log'
require_relative '../../lib/index_tester/query_rating'
require_relative '../../lib/index_tester/harvest_data'
require_relative '../../lib/index_tester/data_base'
require_relative '../../lib/index_tester/generate_tests'

class TestCreateTests < MiniTest::Unit::TestCase
  def setup
    IndexTester::HarvestData.any_instance.stubs(:establish_connection).returns(nil)
    IndexTester::HarvestData.any_instance.stubs(:tables).returns(['orders','orders','orders'])
    IndexTester::HarvestData.any_instance.stubs(:record_counts).returns(Hash['orders',2])
    IndexTester::HarvestData.any_instance.stubs(:missing_indexes).returns([true,true,false])
    IndexTester::HarvestData.any_instance.stubs(:scanned_counts).returns([2,2,1])
    IndexTester::HarvestData.any_instance.stubs(:returned_counts).returns([2,2,1])
    fixture_log = File.dirname(__FILE__) + '/fixture/query.log'
    @queries = IndexTester::ReadLog.new(fixture_log).unique_selects
    @harvester = IndexTester::HarvestData.new(IndexTester::DataBase.new, @queries)
    @tests = IndexTester::GenerateTests.new(@harvester)
  end

  def test_queries
    assert_equal 2, @harvester.record_counts[@harvester.tables[0]]
    assert_equal false, @harvester.missing_indexes[2]
    assert_equal 1, @harvester.scanned_counts[2]
    assert_equal 1, @harvester.returned_counts[2]
    assert_operator 50, :<, @harvester.rating(2)
  end
  def test_making_tests
    test_code = @tests.test_code
    File.open('generated_test.rb', 'w') {|f| f.puts test_code}
    refute_equal '', test_code
  end
end
