require_relative 'helper'

describe Automaton do
  before do
    file = File.expand_path(File.dirname(__FILE__) + '/fixtures/automaton/ab.txt')
    @afd = Automaton.from_file file
    file = File.expand_path(File.dirname(__FILE__) + '/fixtures/automaton/ab-nd')
    @afnd = Automaton.from_file file
  end

  describe 'check word' do
    it 'returns true of the word is accepted' do
      deny   @afd.check_word ''
      deny   @afd.check_word 'a'
      deny   @afd.check_word 'b'
      deny   @afd.check_word 'aa'
      assert @afd.check_word 'ab'
      deny   @afd.check_word 'aba'
    end
  end

  describe 'deterministic?' do
    it 'returns true if the automaton is deterministic' do
      assert @afd.deterministic?
      deny @afnd.deterministic?
    end
  end

  describe 'get_deterministic' do
    it 'returns a deterministic version of the Automaton' do
      afd = @afnd.get_deterministic

      assert afd.deterministic?
      assert afd.check_word 'a'
      assert afd.check_word 'ab'
      deny   afd.check_word 'b'
      deny   afd.check_word 'bb'
    end
  end

  describe 'closure' do
    before do
      file = File.expand_path(File.dirname(__FILE__) + '/fixtures/automaton/ab-nd-cy')
      @cycle = Automaton.from_file file
    end

    it 'returns the closure of the Automaton' do

    end

    it 'cycle' do
      deny @cycle.deterministic?

      afd = @cycle.get_deterministic

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
    a = Automaton.from_regular_expression r, ThompsonConstructionVisitor
  end

  it 'example' do

  end

end
