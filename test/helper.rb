require 'asciidoctor'
require 'rexml/document'
require 'minitest'

require_relative '../lib/dita-topic'

class String
  def to_dita
    return Asciidoctor.convert self, backend: 'dita-topic', standalone: true, logger: false
  end
end

class Minitest::Test
  def assert_xpath_count xml, exp, xpath, msg=nil
    assert_equal exp, REXML::XPath.match((REXML::Document.new xml), xpath).length, msg
  end

  def assert_xpath_equal xml, exp, xpath, msg=nil
    assert_equal exp, REXML::XPath.first((REXML::Document.new xml), xpath).to_s.strip, msg
  end

  def assert_xpath_includes xml, obj, xpath, msg=nil
    assert_includes REXML::XPath.match((REXML::Document.new xml), xpath).map { |s| s.to_s.strip }, obj, msg
  end
end
