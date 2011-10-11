#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/normed_array'

class TestNormedArray < Test::Unit::TestCase
  context "norm an array" do
    setup do
      @a = ServerHealth::NormedArray.new([1,2,3])     
    end
    should "return min and max values" do
      assert_equal 1, @a.min
      assert_equal 3, @a.max
    end
  end
  context "norm an array" do
    setup do
      @a = ServerHealth::NormedArray.new([110, 200, 1000])     
    end
    should "return the normed min and max" do
      data = @a.get_normed_data
      assert_equal 11.0, data.min
      assert_equal 100, data.max
    end
    should "return the normed min and max in a zoomed range" do
      data = @a.get_normed_data(100,2100)
      assert_equal 0.5, data.min
      assert_equal 45.0, data.max
    end
  end
  context "norm an date array" do
    setup do
      @a = ServerHealth::NormedDateArray.new(["2011-06-01","2011-06-02 06:48","2011-06-03 06:50"])     
    end
    should "return min and max values" do
      dates = @a.get_normed_dates
      assert_equal 0, dates.min
      assert_equal 50, dates[1]
      assert_equal 100, dates.max
    end
  end

end

