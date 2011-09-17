#!/usr/local/bin/ruby

$LOAD_PATH.push(File.dirname($0))

require 'config.rb'
require 'dmaildata.rb'
require 'num-utils.rb'

require 'rubygems'
require 'sqlite3'
require 'tmail'
require 'nkf'
require 'action_mailer'
require 'gettext'
require 'date'

# メールメッセージのパース＆データの登録
txt = STDIN.read
msg = TMail::Mail.parse(txt)
dmaildb = DMailDB.new

to_addr = msg.from
user_id = msg.to[0].slice(/(^.*)@.*/, 1)
date = Date.today
date = Date.new(msg.date.year, msg.date.month, msg.date.day) if msg.date

d = NKF.nkf("-w", msg.subject).sub(/(^.*)([0-9]{4}[\/-][0-9]+[\/-][0-9]+)(.*$)/){$2}
dd = d.split(/[-\/]/).map{|i| i.to_i}
date = Date.new(dd[0], dd[1], dd[2]) if /^[0-9]{4}[\/-][0-9]{1,2}[\/-][0-9]{1,2}$/ =~ d


i = 0
NKF.nkf("-w", msg.body).each do |r|
  r.gsub!(/[ \t\n]/, '')
  if r.length > 0 && /^[0-9]+$/ =~ r then
    i = 1
    value = r.to_i
    dmaildb.insert({:timestamp=> date.to_ss,
		:tag=> 'VALUE', :user_id=> user_id, :value=> value})
    break
  end
end

exit if i == 0

# 返信メールの作成
GetText.locale = 'ja'

class DmailMailer < ActionMailer::Base
  @@default_charset = 'iso-2022-jp'
  @@encode_subject = false
  @@dmaildb = nil
  @@user_id = nil
  @@calc_cache = Hash.new

  def load_report_msg(f)
  end

  def calc(op)
    return @@calc_cache[op] if @@calc_cache.key?(op)
    r = 0

    if    op == :today_actual or op == :day0_actualthen
      r = @@dmaildb.sum_values({:timestamp=>@@date.to_ss,
      			       :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :yesterday_actual or op == :day1_actual then
      r = @@dmaildb.sum_values({:timestamp=>(@@date-1).to_ss,
      			       :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :day2_actual then
      r = @@dmaildb.sum_values({:timestamp=>(@@date-2).to_ss,
      			       :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :day3_actual then
      r = @@dmaildb.sum_values({:timestamp=>(@@date-3).to_ss,
      			       :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :day4_actual then
      r = @@dmaildb.sum_values({:timestamp=>(@@date-4).to_ss,
      			       :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :day5_actual then
      r = @@dmaildb.sum_values({:timestamp=>(@@date-5).to_ss,
      			       :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :day6_actual then
      r = @@dmaildb.sum_values({:timestamp=>(@@date-6).to_ss,
      			       :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :lastweek_actual or op == :day7_actualthen
      r = @@dmaildb.sum_values({:timestamp=>(@@date-7).to_ss,
      			       :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :day8_actual then
      r = @@dmaildb.sum_values({:timestamp=>(@@date-8).to_ss,
      			       :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :lastweek_tomorrow then
      r = @@dmaildb.sum_values({:timestamp=>(@@date-6).to_ss,
      			       :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :lastmonth_tomorrow then
      r = @@dmaildb.sum_values({:timestamp=>(@@date-28+1).to_ss,
      			       :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :thisweek_sum then
      r = @@dmaildb.sum_values(
      	{:timestamp_begin=>@@date.last_monday.to_ss, :timestamp_end=>@@date.to_ss,
      	 :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :lastweek_sum then
      r = @@dmaildb.sum_values(
      	{:timestamp_begin=>(@@date - 7).last_monday.to_ss,
   	 :timestamp_end=>(@@date - 7).to_ss,
      	 :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :thismonth_sum then
      r = @@dmaildb.sum_values(
      	{:timestamp_begin=>Date.new(@@date.year, @@date.month, 1).to_ss,
         :timestamp_end=>@@date.to_ss, :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :lastyear_sum then
      dd = Date.new(@@date.year-1, @@date.month, -1)
      dd = @@date if dd.day > @@date.day
      r = @@dmaildb.sum_values(
      	{:timestamp_begin=>Date.new(@@date.year-1,@@date.month,1).to_ss,
   	 :timestamp_end=>Date.new(@@date.year-1,@@date.month, dd.day).to_ss,
      	 :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :lastmonth_sum then
      dd = Date.new(@@date.year, @@date.month-1, -1)
      dd = @@date if dd.day > @@date.day
      r = @@dmaildb.sum_values(
      	{:timestamp_begin=>Date.new(@@date.year,@@date.month-1,1).to_ss,
   	 :timestamp_end=>Date.new(@@date.year,@@date.month-1, dd.day).to_ss,
      	 :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :thisweek_avg then
      r = @@dmaildb.avg_values(
      	{:timestamp_begin=>@@date.last_monday.to_ss, :timestamp_end=>@@date.to_ss,
      	 :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :lastweek_avg then
      r = @@dmaildb.avg_values(
      	{:timestamp_begin=>(@@date - 7).last_monday.to_ss,
   	 :timestamp_end=>(@@date - 7).to_ss,
      	 :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :thismonth_avg then
      r = @@dmaildb.avg_values(
      	{:timestamp_begin=>Date.new(@@date.year, @@date.month, 1).to_ss,
         :timestamp_end=>@@date.to_ss, :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :lastyear_avg then
      dd = Date.new(@@date.year-1, @@date.month, -1)
      dd = @@date if dd.day > @@date.day
      r = @@dmaildb.avg_values(
      	{:timestamp_begin=>Date.new(@@date.year-1,@@date.month,1).to_ss,
   	 :timestamp_end=>Date.new(@@date.year-1,@@date.month, dd.day).to_ss,
      	 :user_id=>@@user_id, :tag=>'VALUE'})
    elsif op == :today_target then
      r = @@dmaildb.sum_values(
      	{:timestamp=>@@date.to_ss,
      	 :user_id=>@@user_id, :tag=>"TARGET"})
    elsif op == :thisweek_target then
      r = @@dmaildb.sum_values(
      	{:timestamp_begin=>@@date.last_monday.to_ss,
	 :timestamp_end=>(@@date.last_monday + 6).to_ss,
      	 :user_id=>@@user_id, :tag=>"TARGET"})
    elsif op == :thismonth_target then
      r = @@dmaildb.sum_values(
      	{:timestamp_begin=>Date.new(@@date.year, @@date.month, 1).to_ss,
         :timestamp_end=>Date.new(@@date.year, @@date.month, -1).to_ss,
      	 :user_id=>@@user_id, :tag=>"TARGET"})
    elsif op == :total_sum then
      r = @@dmaildb.sum_values(
      	{:timestamp_begin=>Date.new(1970,1,1).to_ss, :timestamp_end=>@@date.to_ss,
      	 :user_id=>@@user_id, :tag=>'VALUE'})
    else
      r = nil
    end

    @@calc_cache[op] = r
    return r
  end

  def reportMail(to_addr, date, user_id, dmaildb)
    @@dmaildb = dmaildb
    @@user_id = user_id
    @@date = date

    from $FROM_ADDR
    recipients to_addr
    cc $CC_ADDR
    sent_on = Date.today
    subject '=?ISO-2022-JP?B?' + NKF.nkf('-j', 
    			"【日報】#{date.strftime("%Y/%m/%d")}(#{date.wday_name})"
    		).split(//,1).pack('m').chomp + '?='

    msg = eval('"'+File.read($REPORT_MSG_FILE)+'"')
    body NKF.nkf('-j', msg)

  end
end

ActionMailer::Base.smtp_settings = {
        :address => $SMTP_SERVER,
        :port => 25 }

DmailMailer.reportMail($TO_ADDR.push(to_addr), date, user_id, dmaildb).deliver

