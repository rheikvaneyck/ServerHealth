#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/credentials'

class TestCredentials < Test::Unit::TestCase
  context "reading credentials from file" do
    setup do
      @c = ServerHealth::Credentials.new("fritz","pw", "fritz.box")
    end
    should "return username and password" do
      assert_equal "fritz", @c.username
      assert_equal "pw", @c.password
    end
    should "return username and password from file" do
      assert_not_equal 0, @c.read_from_yaml("../config/credentials.yml")
      assert_equal "marcus", @c.username
      assert_equal "geheim", @c.password
      assert_equal "home.server.com", @c.server
    end
  end
end