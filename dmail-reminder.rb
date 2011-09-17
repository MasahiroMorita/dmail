#!/usr/local/bin/ruby

$LOAD_PATH.push(File.dirname($0))

require 'config.rb'
require 'rubygems'
require 'action_mailer'
require 'gettext'
require 'nkf'
require 'date'

require 'num-utils.rb'

GetText.locale = 'ja'

class DmailMailer < ActionMailer::Base
  @@default_charset = 'iso-2022-jp'
  @@encode_subject = false

  def remainderMessage
    date = Date.today - $DATE_OFFSET

    from $FROM_ADDR
    recipients $TO_ADDR
    cc $CC_ADDR
    sent_on = Time.now
    subject '=?ISO-2022-JP?B?' + NKF.nkf('-j', 
    		"【日報入力】#{date.strftime('%Y/%m/%d')}(#{date.wday_name})の実績を送信してください"
            ).split(//,1).pack('m').chomp + '?='

    body NKF.nkf('-j', eval('"'+File.read($REMIND_MSG_FILE)+'"'))
  end
end

ActionMailer::Base.smtp_settings = {
	:address => $SMTP_SERVER,
	:port => 25 }

DmailMailer.remainderMessage.deliver

