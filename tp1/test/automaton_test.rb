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

  describe 'check word' do
    it 'returns true of the word is accepted' do
      deny   load_afd.check_word ''
      deny   load_afd.check_word 'a'
      deny   load_afd.check_word 'b'
      deny   load_afd.check_word 'aa'
      assert load_afd.check_word 'ab'
      deny   load_afd.check_word 'aba'
    end
  end

  describe 'deterministic?' do
    it 'returns true if the automaton is deterministic' do
      assert load_afd.deterministic?
      deny   load_afnd.deterministic?
    end
  end

  describe 'get_deterministic' do
    it 'returns a deterministic version of the Automaton' do
      afd = load_afnd.get_deterministic

      assert afd.deterministic?
      assert afd.check_word 'a'
      assert afd.check_word 'ab'
      deny   afd.check_word 'b'
      deny   afd.check_word 'bb'
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

  it 'reads lambda from the file' do

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
