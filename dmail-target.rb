#!/usr/local/bin/ruby

$LOAD_PATH.push(File.dirname($0))

require 'config.rb'
require 'dmaildata.rb'
require 'num-utils.rb'

require 'rubygems'
require 'sqlite3'
require 'date'
require 'optparse'

parser = OptionParser.new

$action = nil
$user_id = nil
$month = Date.today
$value = 0

parser.on('-a', '--add=VALUE', Integer, "目標値を登録する") { |arg|
  $value = arg
  $action = "add"
}
parser.on('-u', '--user=USER', String, "ユーザIDを指定する") { |arg|
  $user_id = arg
}
parser.on('-m', '--month=MONTH', String, "対象月を指定する") { |arg|
  $month = Date.parse(arg)
}
parser.on('-l', '--list-target', "目標値を一覧する") {
  $action = 'list'
}
parser.on('-d', '--daily-list', "日ごとの表示") {
  $action = 'daily'
}

begin
  parser.parse!

  raise OptionParser::ParseError, "処理が指定されていません" unless $action
  exit unless $user_id

  dmaildb = DMailDB.new
  if $action == "add" then
    dmaildb.insert({:timestamp=> $month.to_ss,
                    :tag=> 'TARGET', :user_id=> $user_id, :value=> $value})
  elsif $action == "list" then
    value = dmaildb.sum_values({:timestamp_begin=> Date.new($month.year, $month.month, 1).to_ss,
                       :timestamp_end=> Date.new($month.year, $month.month, -1).to_ss,
		       :tag=> 'TARGET', :user_id=> $user_id})
    puts "#{$month.strftime('%Y/%m')}: #{value}"
  elsif $action == 'daily' then
    i = Date.new($month.year, $month.month, 1)
    while i <= Date.new($month.year, $month.month, -1) do
	value = dmaildb.sum_values({:timestamp=> i.to_ss, :tag=>'TARGET', :user_id=> $user_id})
	puts "#{i.strftime('%Y/%m/%d')}: #{value}"
	i = i + 1 
    end
  end
rescue OptionParser::ParseError => err
  $stderr.puts err.message
  $stderr.puts parser.help
end

