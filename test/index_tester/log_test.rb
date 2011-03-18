require_relative '../../lib/index_tester/read_log'
require_relative '../../lib/index_tester/harvest_data'

class TestReadLog < MiniTest::Unit::TestCase
  def setup
    @reader = IndexTester::ReadLog.new('fixture/query.log')
  end

  def test_select
    assert_equal 3, @reader.unique_log_entries.size
    assert_equal 3, @reader.unique_selects.size
    refute_equal @reader.unique_selects[0], @reader.unique_selects[1]
  end
end

class TestHarvestData < MiniTest::Unit::TestCase
  def setup
    IndexTester::HarvestData.any_instance.stubs(:establish_connection).returns(nil)
    IndexTester::HarvestData.any_instance.stubs(:record_counts).returns(Hash['orders',2])
    IndexTester::HarvestData.any_instance.stubs(:missing_indexes).returns([true,true,false])
    IndexTester::HarvestData.any_instance.stubs(:scanned_counts).returns([2,2,1])
    IndexTester::HarvestData.any_instance.stubs(:returned_counts).returns([2,2,1])
    @queries = IndexTester::ReadLog.new('fixture/query.log').unique_selects
    @harvester = IndexTester::HarvestData.new(IndexTester::DataBase.new, @queries)
  end

  def test_table_sizes
    assert_equal 1, @harvester.record_counts.size
    assert_operator 0, :<, @harvester.record_counts['orders']
  end
  def test_explain
    assert_equal 3, @harvester.get_explains.size
    assert_equal 'TABLE orders', @harvester.get_explains[0]
    assert_equal 'TABLE orders', @harvester.get_explains[1]
    assert_equal 'TABLE orders WITH INDEX onum', @harvester.get_explains[2]
  end
  def test_explain_detail
    assert_equal [true, true, false], @harvester.missing_indexes
    assert_equal [2,2,1], @harvester.scanned_counts
  end
end
