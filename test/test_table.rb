require 'minitest/autorun'
require_relative 'helper'

class TableTest < Minitest::Test
    def test_table
        xml = <<~EOF.chomp.to_dita
        [cols="1,1"]
        |===
        |Header 1 |Header 2
        |Cell 1   |Cell 2
        |===
        EOF
      
        assert_xpath_equal xml, 'Header 1', '//table/tgroup/tbody/row[1]/entry[1]/p/text()'
        assert_xpath_equal xml, 'Cell 2', '//table/tgroup/tbody/row[2]/entry[2]/p/text()'
    end
end
