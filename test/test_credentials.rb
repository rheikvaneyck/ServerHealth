#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/credentials'

class TestCredentials < Test::Unit::TestCase
  context "reading credentials from file" do
    should "return ssh user and password" do
      credential_keys = ["ssh_user", "ssh_pw", "ssh_server"]
      credentials = ServerHealth::Credentials.read_from_yaml("../config/credentials_sample.yml",credential_keys)
      assert_not_equal 0, credentials.length
      assert_equal "marcus", credentials[:ssh_user]
      assert_equal "geheim", credentials[:ssh_pw]
      assert_equal "home.server.com", credentials[:ssh_server]
    end
    should "return email recepients" do
      credential_keys = ["email_to"]
      credentials = ServerHealth::Credentials.read_from_yaml("../config/credentials_sample.yml",credential_keys)
      assert_not_equal 0, credentials.length
      assert_equal "user@server.com, user2@server.com", credentials[:email_to]
      assert_equal "user@server.com", credentials[:email_to].split(",")[0]
    end
  end
end