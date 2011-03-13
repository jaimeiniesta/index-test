require_relative '../lib/read_log'

class TestReadLog < MiniTest::Unit::TestCase
  def setup
    @reader = IndexTester::ReadLog.new('fixture/query.log')
  end

  def test_read
    assert_equal "select * from orders;", @reader.query[0]
    assert_equal "the stack trace", @reader.stack_trace[0]
    assert_equal "2011-03-13", @reader.timestamp[0]
  end

end

