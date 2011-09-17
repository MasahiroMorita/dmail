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
$file = nil
$separator = ','
$timestamp_begin = '1970-01-01 00:00:00'
$timestamp_end = '2500-12-31 00:00:00'
$tag = 'VALUE'

parser.on('-l', '--load-csv=FILENAME', String, "データファイルを読み込む") { |arg|
  $file = arg
  $action = "load"
}
parser.on('-u', '--user=USER', String, "ユーザIDを指定する") { |arg|
  $user_id = arg
}
parser.on('-d', '--dump-data', "データをダンプする") {
  $action = 'dump'
}
parser.on('-s', '--start-date=DATE', String, "データの取得開始日") { |arg|
  $timestamp_begin = Date.parse(arg).to_ss
}
parser.on('-e', '--end-date=DATE', String, "データの取得終了日") { |arg|
  $timestamp_end = Date.parse(arg).to_ss
}
parser.on('-S', '--separator=SEP', String, "フィールドの区切り文字を指定する(TAB/CSV)") { |arg|
  $separator = "\t" if arg == 'TAB' or arg == 'tab'
  $separator = ","  if arg == 'CSV' or arg == 'csv'
}
parser.on('-T', '--daily-target', "日毎の目標値として読み込みを行います") {
  $tag = "TARGET"
}

begin
  parser.parse!

  raise OptionParser::ParseError, "処理が指定されていません" unless $action
  exit unless $user_id

  dmaildb = DMailDB.new
  if $action == "load" then
    data = []
    File.readlines($file).each do |r|
      r.chop!
      d = r.split($separator)
      data.push([Date.parse(d[0]).to_ss, d[1]])
    end
    dmaildb.load_historical_data($user_id, data, $tag)
  elsif $action == "dump" then
    result = dmaildb.dump_historical_data({:user_id=> $user_id, :timestamp_begin=> $timestamp_begin,
                                  :timestamp_end=> $timestamp_end, :tag=> $tag})
    result.each do |r|
      print "#{r[0]}#{$separator}#{r[1]}\n"
    end
  end
rescue OptionParser::ParseError => err
  $stderr.puts err.message
  $stderr.puts parser.help
end

