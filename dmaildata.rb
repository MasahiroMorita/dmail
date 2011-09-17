
class DMailDB
  def initialize
    @db = SQLite3::Database.new($DMAIL_DB)
  end

  def insert(record)
    delete_if_exist({:timestamp=>record[:timestamp], :user_id=>record[:user_id],
                    :tag=>record[:tag]})
    @db.execute("insert into dmail_data values (:id, :timestamp, :user_id, :tag, :value)",
                record)
  end

  def delete_if_exist(cond)
    sql = "delete from dmail_data where " + build_where_condition(cond)
    @db.execute(sql)
  end

  def sum_values(cond)
    sql = "select sum(value) from dmail_data where " + build_where_condition(cond)
    result = @db.get_first_value(sql)
    return result
  end

  def count_values(cond)
    sql = "select count(value) from dmail_data where " + build_where_condition(cond)
    result = @db.get_first_value(sql)
    return result
  end

  def avg_values(cond)
    sql = "select avg(value) from dmail_data where " + build_where_condition(cond)
    result = @db.get_first_value(sql)
    return result
  end

  def load_historical_data(user_id, data, tag)
    data.each do |d|
      @db.execute("insert into dmail_data values (:id, :timestamp, :user_id, :tag, :value)",
                  {:timestamp=> d[0], :value=> d[1], :user_id=> user_id, :tag=> tag})
    end
  end

  def dump_historical_data(cond)
    sql = "select timestamp, value from dmail_data where " + build_where_condition(cond)
    @db.query(sql)
  end

  def build_where_condition(cond)
    sql = ""
    sep = ""
    if cond.key?(:timestamp_begin) && cond.key?(:timestamp_end) then
      sql = sql + "timestamp between '#{cond[:timestamp_begin]}' and '#{cond[:timestamp_end]}' "
      cond.delete(:timestamp_begin)
      cond.delete(:timestamp_end)
      sep = "and "
    end
    if cond.key?(:timestamp) then
      sql = sql + sep + "timestamp='#{cond[:timestamp]}' "
      sep = "and "
    end
    if cond.key?(:user_id) then
      sql = sql + sep + "user_id='#{cond[:user_id]}' "
      sep = "and "
    end
    if cond.key?(:tag) then
      sql = sql + sep + "tag='#{cond[:tag]}' "
      sep = "and "
    end
    return sql
  end
end

if __FILE__ == $0 then
require 'config.rb'
require 'rubygems'
require 'sqlite3'

db = DMailDB.new
db.insert({:timestamp => '2011-06-20 00:00:00',
          :user_id => 'test-01', :tag => '売上', :value => 234})
db.insert({:timestamp => '2011-06-21 00:00:00',
          :user_id => 'test-01', :tag => '売上', :value => 301})
db.insert({:timestamp => '2011-06-22 00:00:00',
          :user_id => 'test-01', :tag => '売上', :value => 338})
db.insert({:timestamp => '2011-06-23 00:00:00',
          :user_id => 'test-01', :tag => '売上', :value => 184})
db.insert({:timestamp => '2011-06-24 00:00:00',
          :user_id => 'test-01', :tag => '売上', :value => 495})

db.insert({:timestamp => '2011-06-24 00:00:00',
          :user_id => 'test-01', :tag => '売上', :value => 666})

p db.sum_values({:timestamp_begin => '2011-06-01 00:00:00',
                :timestamp_end => '2011-06-30 00:00:00',
	        :user_id => 'test-01', :tag => '売上'})

p db.count_values({:timestamp_begin => '2011-06-01 00:00:00',
                :timestamp_end => '2011-06-30 00:00:00',
	        :user_id => 'test-01', :tag => '売上'})

db.delete_if_exist({:timestamp_begin => '2011-06-01 00:00:00',
                :timestamp_end => '2011-06-30 00:00:00',
	        :user_id => 'test-01', :tag => '売上'})
end
