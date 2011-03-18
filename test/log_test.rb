require_relative '../lib/read_log'

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
    db = IndexTester::DataBase.new
    @queries = IndexTester::ReadLog.new('fixture/query.log').unique_selects
    @harvester = IndexTester::HarvestData.new(db, @queries)
  end

  def test_table_sizes
    assert_equal 1, @harvester.get_record_counts.size
    assert_operator 0, :<, @harvester.get_record_counts['orders']
  end
  def test_explain
    assert_equal 3,@harvester.get_explains.size
    assert_equal '',@harvester.get_explains
  end
  def test_explain_detail
    assert_equal [true, true, false], @harvester.missing_indexes
    assert_equal [2,2,1], @harvester.scanned_counts
  end
end
