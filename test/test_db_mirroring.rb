require 'rubygems'
require 'test/unit'
require 'pp'

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
require 'sql_server_adapter.rb'

class Reader < Minus5::SqlServerAdapter

  def read
    execute("select * from programmers").each(:symbolize_keys => true)
  end

  def failover
    execute("use master; ALTER DATABASE activerecord_unittest_mirroring SET PARTNER FAILOVER")
  end

end

class DbMirroring < Test::Unit::TestCase

  def rollback_transaction(client)
    client.execute("BEGIN TRANSACTION").do
    yield
  ensure
    client.execute("ROLLBACK TRANSACTION").do
  end
  
  def setup
    @reader = Reader.new({:username => "rails", 
                           :password => "", 
                           :host => "bedem", 
                           :mirror_host => "mssql",
                           :database => "activerecord_unittest_mirroring"})
  end

  def test_get_params
    columns = @reader.send(:get_params, 'programmers')
    assert_equal 3, columns.size
    assert columns.include?("id")
    assert columns.include?("first_name")
    assert columns.include?("last_name")
  end

  def test_insert
    rollback_transaction(@reader) do 
      id = @reader.insert('programmers', {:first_name => "Igor", :last_name => "Anic"})
      assert_equal 4, @reader.select_value("select count(*) from programmers")
      @reader.delete('programmers', {:id => id})
      assert_equal 3, @reader.select_value("select count(*) from programmers")
    end    
  end
  
  def _test_read
    rows = @reader.read
    data_test rows
    pp rows
    @reader.failover
    rows = @reader.read
    data_test rows
  end

  def data_test(rows)
    assert_equal 3, rows.size
    assert "Sasa", rows[0][:first_name]
  end
  
end
