#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/credentials'

class TestCredentials < Test::Unit::TestCase
  context "reading credentials from file" do
    setup do
      @c = ServerHealth::Credentials.new()
    end
    should "return ssh user and password" do
      credential_keys = ["ssh_user", "ssh_pw", "ssh_server"]
      credentials = @c.read_from_yaml("../config/credentials_sample.yml",credential_keys)
      assert_not_equal 0, credentials.length
      assert_equal "marcus", credentials[:ssh_user]
      assert_equal "geheim", credentials[:ssh_pw]
      assert_equal "home.server.com", credentials[:ssh_server]
    end
  end
end