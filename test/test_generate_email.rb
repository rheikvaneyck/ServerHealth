#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/generate_email'

class TestEMail < Test::Unit::TestCase
  context "email generator helper" do
    setup do
      images = ["../downloads/chart-2011-07-01-20-49.png"]
      @email = ServerHealth::EMail.new(images)
    end
    should "return MIME marker" do
       assert_match /\w{20}/, @email.gen_marker
    end
    should "return a content-id" do
      assert_match /\d+[.]serverhealth@\w+[.]*\w+/, @email.gen_content_id
    end
    should "return encoded content" do
      marker = @email.gen_marker
      content_structs = @email.gen_mime_content(marker)
      assert_equal "chart-2011-07-01-20-49.png", content_structs[0][:file_name]
    end
    should "return file_name replacement" do
      str = %{		    <IMG SRC='cid:12345' ALIGN="bottom" BORDER="0" ALT="Storage Pie" style="border: solid 2px #bbb;width 250px;height: 250px;margin: 10px;"> }
      assert_equal str, @email.set_cid!("chart-2011-07-01-20-49.png", "12345")
    end
  end  
  context "email generator" do
    setup do
      images = ["../downloads/chart-2011-07-01-20-49.png"]
      @email = ServerHealth::EMail.new(images)
    end
    should "return successfull import of html-report" do
       assert @email.import_html("../reports/2011-07-02-report.html")
    end
    should "return length of generated email file" do
      @email.import_html("../reports/2011-07-02-report.html")
      assert_not_equal 0, @email.create_elm("../mails/2011-07-02-report.elm")
    end
  end
end
