#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/send_report'
require File.dirname(__FILE__) + '/../lib/Server-Health/credentials'

class TestMailSender < Test::Unit::TestCase
  context "send email report" do
    setup do
      c = ServerHealth::Credentials.new()
      credential_keys = ["smtp_user", "smtp_pw", "smtp_server", "smtp_port", "smtp_host"]
      credential_file = "../config/credentials.yml"
      @credentials = c.read_from_yaml(credential_file,credential_keys)
      # email_file = "../mails/email.elm"
      email_file = "../mails/2011-07-02-report.elm"
      @email_sender = ServerHealth::MailSender.new(email_file, @credentials)
    end
    should "return initialized MailSender" do
      assert_not_nil @email_sender.mail_text
      assert_equal @credentials[:smtp_server], @email_sender.smtp_server
      assert_equal @credentials[:smtp_port], @email_sender.smtp_port
      assert_equal @credentials[:smtp_host], @email_sender.smtp_host
      assert_equal @credentials[:smtp_user], @email_sender.smtp_user
      assert_equal @credentials[:smtp_pw], @email_sender.smtp_pw
    end
    should "return msg that message sent" do
      c = ServerHealth::Credentials.new()
      credential_keys = ["email_from", "email_to"]
      credentials = c.read_from_yaml("../config/credentials.yml",credential_keys)
      email_envelop = "From: #{credentials[:email_from]}\nTo: #{credentials[:email_to]}\nSubject: TestUnit Mail\n"
      @email_sender.mail_text = email_envelop + @email_sender.mail_text
      assert_equal "message from #{credentials[:email_from]} to #{credentials[:email_to]} sent", @email_sender.send_report(credentials[:email_from], [credentials[:email_to]])
    end
  end
end
