require_relative 'helper'

describe Automaton do
  describe 'from_file' do
    it 'reads a file and returns the automaton' do
      file = File.expand_path(File.dirname(__FILE__) + '/fixtures/automaton/ab.txt')
      from_file = Automaton.from_file file

      assert_equal load_afd.states, from_file.states
      assert_equal load_afd.alphabet, from_file.alphabet
      assert_equal load_afd.initial_state, from_file.initial_state
      assert_equal load_afd.final_states, from_file.final_states
      assert_equal load_afd.graph, from_file.graph
    end
  end

  describe 'creation' do
    it 'starts with all empty attributes' do
      automaton = Automaton.new

      assert_equal [], automaton.states
      assert_equal [], automaton.alphabet
      assert_equal [], automaton.final_states
      assert_equal nil, automaton.initial_state
      assert automaton.graph.empty?
    end

    it 'adds a transition to the automaton represented in the graph' do
      automaton = Automaton.new
      automaton.add_transition 'from', '1', 'to'
      expected = { '1' => ['to'] }

      deny automaton.graph.empty?
      assert_equal expected, automaton.graph['from']
    end

    it 'accepts multiples destination states for the same transition' do
      automaton = Automaton.new
      automaton.add_transition 'from', '1', 'to'
      automaton.add_transition 'from', '1', 'to2'
      automaton.add_transition 'from', '1', 'to3'
      automaton.add_transition 'from', '2', 'to'

      assert_equal %w(to to2 to3), automaton.graph['from']['1']
      assert_equal %w(to), automaton.graph['from']['2']
    end
  end

  describe 'check word' do
    it 'returns true when a word is accepted' do
      deny load_afd.check_word ''
      deny load_afd.check_word 'a'
      deny load_afd.check_word 'b'
      deny load_afd.check_word 'aa'
      assert load_afd.check_word 'ab'
      deny load_afd.check_word 'aba'
    end
  end

  describe 'deterministic?' do
    it 'returns true if the automaton is deterministic' do
      assert load_afd.deterministic?
      deny load_afnd.deterministic?
    end
  end

  describe 'get_deterministic' do
    it 'returns a deterministic version of the Automaton' do
      afd = load_afnd.get_deterministic

      assert afd.deterministic?
      assert afd.check_word 'a'
      assert afd.check_word 'ab'
      deny afd.check_word 'b'
      deny afd.check_word 'bb'
    end
  end

  describe 'minimize' do
    it 'returns the minimum DFA which recognizes the same language than the given automaton' do
    end
  end

  describe 'closure' do
    it 'returns the closure of the Automaton' do
    end

    it 'cycle' do
      deny load_cycle.deterministic?

      afd = load_cycle.get_deterministic

      assert afd.deterministic?
    end
  end

  describe 'to_dot' do
    it 'Return a representation of the Automaton in DOT lang' do
      expected = <<-EOS.gsub(/^ {8}/, '')
        strict digraph {
        \trankdir=LR;
        \tnode [shape = none, label = ""]; qd;
        \tnode [label = "\\N", width= 0.5, height = 0.5];
        \tnode [shape = doublecircle]; q2;
        \tnode [shape = circle];
        \tqd -> q0
        \tq0 -> q1 [label="a"]
        \tq1 -> q2 [label="b"]
        }
      EOS

      assert_equal expected.strip, load_afd.to_dot
    end

    it 'return a representation of the Automaton using TL-lang' do
      expected = <<-EOS.gsub(/^ {8}/, '')
        q0	q1	q2
        a	b
        q0
        q2
        q0	a	q1
        q1	b	q2
      EOS

      assert_equal expected, load_afd.to_file
    end
  end

  describe 'complement' do
    it 'returns an automaton representing the complement' do
      afd = load_afd
      complemented = afd.complement
      expected = afd.states - afd.final_states

      assert_equal expected, complemented.final_states
    end
  end

  describe 'intersection' do
    it 'computes the intersection of two automaton' do
      afd = load_afd
      afnd = load_afnd.get_deterministic
      intersection = afd.intersect load_afnd

      deny afd.check_word 'a'
      assert afd.check_word 'ab'
      assert afnd.check_word 'a'
      assert afnd.check_word 'ab'
      deny intersection.check_word 'a'
      assert intersection.check_word 'ab'
    end
  end

  # describe 'reverse' do
    # before do
      # @original = load_afd
      # @reversed = @original.reverse
    # end

    # it 'converts the initial state into a final state' do
      # assert_equal [@original.initial_state], @reversed.final_states
    # end

    # it 'makes regular states to the final states' do
      # assert @original.final_states.include? 'q2'
      # deny @reversed.final_states.include? 'q2'
      # assert @reversed.states.include? 'q2'
    # end

    # it 'creates a new initial state and add lambda-transitions to the old final states' do
      # is = @reversed.initial_state
      # deny @original.states.include? is
      # assert_equal @original.final_states, @reversed.graph[is]['']
    # end
  # end

  describe 'rename_states' do
    it 'abbreviates and changes every state name in order to improve human reading' do
      afd = load_afd
      prefix = afd.instance_variable_get(:@prefix).dup
      old_states = afd.states.dup

      afd.rename_states

      assert_equal afd.states, old_states.map { |s| s.gsub('q', prefix) }
    end

    it 'increment the prefix of the automaton' do
      afd = load_afd
      prefix = afd.instance_variable_get(:@prefix).dup

      afd.rename_states

      assert_equal prefix.next, afd.instance_variable_get(:@prefix)
    end

    it 'replaces the prefix with the next value passed' do
      afd = load_afd

      assert_equal 'a', afd.instance_variable_get(:@prefix)

      afd.rename_states 't'

      assert_equal 'u', afd.instance_variable_get(:@prefix)
    end
  end

  describe 'as' do
    before do
      @path = File.dirname(__FILE__) + '/fixtures/'
    end

    it 'a' do
      regexp = RegularExpression.from_file File.expand_path(@path + 'regexp1.txt')
      automaton = Automaton.from_file File.expand_path(@path + 'af1.txt')

      assert regexp.to_automaton.equivalent? automaton

    end
  end
end

describe RegularExpression do
  before do
    file = File.expand_path(File.dirname(__FILE__) + '/fixtures/regexp/ab')
    r = RegularExpression.from_file file
    a = r.to_automaton
  end

  it 'example' do
  end
end
