# Web application test path generators
# Copyright (C) 2011 Sarah Vessels <cheshire137@gmail.com>
#  
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, '..', 'parser.rb')
require File.join(base_path, 'test_helper.rb')

class ERBDocumentTest < Test::Unit::TestCase
  def test_elsif_component_expression
    assert_component_expression(fixture('elsif.html'),
                                'elsif.html.erb',
                                '(p1|p2|p3|p4)')
  end
  
  def test_nested_case_when_elsif_component_expression
    assert_component_expression(fixture('nested_case_when.html'),
                                'nested_case_when.html.erb',
                                '((p1|p2|p3)|(p4|p5|p6)|p7)')
  end

  def test_form_transitions
    doc = assert_doc(fixture('_add_updates.html'),
                     '_add_updates.html.erb')
    trans = doc.get_transitions()
    assert_not_nil trans
    assert_equal 2, trans.length
    trans.each do |transition|
      assert_equal transition.class, FormTransition
    end
  end

  def test_loop_if_loop_component_expression
    assert_component_expression(fixture('game_index1-sans_unless.html'),
                                'game_index1-sans_unless.html.erb',
                                'p1.(p2|(p3.p4*.p5))*.p6')
  end

  def test_unless_loop_component_expression
    assert_component_expression(fixture('unless_loop.html'),
                                'unless_loop.html.erb',
                                '((p1.p2*.p3)|NULL)')
  end

  def test_case_when_component_expression
    assert_component_expression(fixture('case_when.html'),
                                'case_when.html.erb',
                                '(p1|p2|p3|p4)')
  end
  
  def test_nested_elsif_component_expression
    assert_component_expression(fixture('nested_elsif.html'),
                                'nested_elsif.html.erb',
                                '((p1|p2)|p3|p4)')
  end

  def test_close_branch_component_expression
    assert_component_expression(fixture('_add_updates.html'),
                                '_add_updates.html.erb',
                                '((p1|p2)|NULL)')
  end

  def test_lvar_component_expression
    # Sometimes the sexp for ERB code can differ based on context, like if
    # "thing.blah()" is parsed versus "if thing = junk; thing.blah(); end"
    # is parsed.
    assert_component_expression(fixture('short_edit.html'),
                                'short_edit.html.erb',
                                '(p1|p2)')
  end
  
  def test_loops_component_expression
    assert_component_expression(fixture('loops.html'),
                                'loops.html.erb',
                                'p1*.p2*.p3*.p4***')
  end

  def test_form_tag_component_expression
    assert_component_expression(fixture('login_index.html'),
                                'login_index.html.erb',
                                'p1')
  end

  def test_javascript_component_expression
    assert_component_expression(fixture('javascript.html'),
                                'javascript.html.erb',
                                '(p1|NULL)')
  end

  def test_multiple_statements_in_erb_tags_component_expression
    assert_component_expression(fixture('multiple_lines_in_erb.html'),
                                'multiple_lines_in_erb.html.erb',
                                'p1.p2')
  end

  def test_multiple_lines_in_erb_tags_component_expression
    assert_component_expression(fixture('nested_loop.html'),
                                'nested_loop.html.erb',
                                'p1.p2.p3*.p4')
  end

  def test_multiple_erb_lines_unequal_ifs_component_expression
    assert_component_expression(fixture('_in_progress.html'),
                                '_in_progress.html.erb',
                                '((((p1|NULL).p2)|p3)|NULL).p4.p5.p6*.p7.p8*.p9.p10.p11.p12.(p13|p14)')
  end

  def test_nested_unequal_ifs_component_expression
    assert_component_expression(fixture('nested_unequal_ifs.html'),
                                'nested_unequal_ifs.html.erb',
                                "(((p1|NULL).p2)|p3)")
  end

  def test_nested_aggregation_component_expression
    assert_component_expression(fixture('game_index2.html'),
                                'game_index2.html.erb',
                                "p1.(p2|(p3.p4*.p5))*.p6")
  end

  def test_nested_aggregation_selection_component_expression
    assert_component_expression(fixture('game_index1.html'),
                                'game_index1.html.erb',
                                '((p1.(p2|(p3.p4*.p5))*.p6)|NULL)')
  end

  def test_nested_if_and_aggregation_component_expression
    assert_component_expression(fixture('top_records.html'),
                                'top_records.html.erb',
                                'p1.(p2|(p3.{p4}.p5)).p6.(p7|(p8.{p9}.p10)).p11')
  end

  def test_nested_if_and_loop_component_expression
    assert_component_expression(fixture('_finished.html'),
                                '_finished.html.erb',
                                '((p1|p2)|NULL).(p3|NULL).(p4|NULL).p5.p6*.p7')
  end

  def test_delete_node
    doc = Parser.new.parse(fixture('login_index.html'), 'login_index.html.erb', URI.parse('/'))
    assert_not_nil doc
    form = doc[0]
    assert_not_nil form
    assert_equal "ERBGrammar::ERBTag", form.class.name
    old_length = doc.length
    deleted_node = doc.content.delete(form)
      assert_equal form, deleted_node, "Expected returned deleted_node to match form"
    assert_not_equal form, doc[0], "New node in index 0 should not be the same as the one we just deleted"
    new_length = doc.length
    assert_equal old_length-1, new_length, "New length of ERBDocument should be 1 less than old length"
  end

  def test_nested_atomic_section
    doc = Parser.new.parse(fixture('_finished.html'), '_finished.html.erb', URI.parse('/'))
    assert_not_nil doc
    # The code in question:
    # <% #Check the state of the game and write out the winners, losers, and drawers.
    #    #Then display the final scores.
    #    if @winner %>
    #     <% if @winner.id == session[:user][:id] %>
    #         <p class="game_result_positive">You won!</p>
    #     <% else %>
    #         <p class="game_result_negative"><%= @winner.email %> won!</p>
    #     <% end %>
    # <% end %>
    if_winner = doc[2]
    assert_not_nil if_winner
    assert_equal "ERBGrammar::ERBTag", if_winner.class.name, "Wrong type of node in slot 0 of ERBDocument"
    assert_not_nil if_winner.content, "Nil content in if-winner ERBTag\nTree: " + doc.to_s
    nodes = if_winner.get_sections_and_nodes()
    assert_equal 1, nodes.length, "Expected one ERBTag child node of if-winner ERBTag"
    if_winner_equal = nodes.first
    sections = if_winner_equal.get_sections_and_nodes().select do |child|
      child.is_a?(AtomicSection)
    end
    assert_equal 1, sections.length, "Expected one atomic section child of if-winner-equal ERBTag: " + sections.inspect
    assert_not_nil if_winner_equal.branch_content, "Expected non-nil branch_content for if-winner-equal ERBTag"
    assert_not_equal 1, if_winner_equal.branch_content.length
    end_tag = if_winner_equal.close
    assert_not_nil end_tag, "Expected 'end' to be close of: " + if_winner_equal.to_s
    assert_equal "end", end_tag.ruby_code()
  end

  def test_square_bracket_accessor_fixnum
    doc = Parser.new.parse(fixture('login_index.html'), 'login_index.html.erb', URI.parse('/'))
    assert_not_nil doc
    form = doc[0]
    assert_not_nil form
    assert_equal "ERBGrammar::ERBTag", form.class.name
    label = form.content.find { |c| 7 == c.index }
    assert_not_nil label
    assert_equal "ERBGrammar::HTMLOpenTag", label.class.name
      assert_equal "label", label.name
    assert_equal 1, label.attributes.length,
      "Should be one attribute on HTML label tag: " + label.to_s
    assert_equal 'for', label.attributes.first.name,
      "First attribute on label tag should be 'for'"
    end_of_block = doc[doc.length-1]
    assert_not_nil end_of_block
    assert_equal "ERBGrammar::ERBTag", end_of_block.class.name
  end

  def test_square_bracket_accessor_range
    doc = Parser.new.parse(fixture('login_index.html'), 'login_index.html.erb', URI.parse('/'))
    assert_not_nil doc
    elements = doc[0..1]
    assert_equal Array, elements.class, "Expected Array return value"
    assert_equal 1, elements.length, "Expected one element"
    assert_equal "ERBGrammar::ERBTag", elements[0].class.name
    assert_equal 0, elements[0].index
  end

  def test_length
    doc = Parser.new.parse(fixture('login_index.html'), 'login_index.html.erb', URI.parse('/'))
    assert_not_nil doc
    assert_equal 1, doc.length,
      "ERB document has all nodes nested within a form_tag, so doc should have length 1"
  end

  private
    def assert_component_expression(erb, file_name, expected)
      doc = assert_doc(erb, file_name)
      actual = doc.component_expression()
      assert_equal expected, actual, "Wrong component expression for " + file_name
    end

    def assert_doc(erb, file_name)
      rails_path = File.join("app", "views", "test", file_name)
      doc = Parser.new.parse(erb, rails_path, URI.parse('http://example.com/'))
      assert_not_nil doc
      doc
    end
end
