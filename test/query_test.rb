require_relative '../lib/read_log'

class TestCreateTests < MiniTest::Unit::TestCase
  def setup
    @queries = IndexTester::ReadLog.new('fixture/query.log').unique_selects
    @harvester = IndexTester::HarvestData.new(IndexTester::DataBase.new, @queries)
  end

  def test_table_sizes
    assert_equal 2, @harvester.record_counts[@harvester.tables[0]]
    assert_equal false, @harvester.missing_indexes[2]
    assert_equal 1, @harvester.scanned_counts[2]
    assert_equal 1, @harvester.returned_counts[2]
    assert_operator 50, :<, @harvester.rating(2)
  end
end
