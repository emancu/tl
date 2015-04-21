require_relative 'automaton_helper'
require_relative 'dot_presenter'

class Automaton
  attr_accessor :graph, :states, :alphabet, :initial_state, :final_states

  def self.from_file(file)
    AutomatonHelper.read_from_file file, new
  end

  def initialize
    @states = []
    @alphabet = []
    @final_states = []
    @graph = Hash.new { |hash, key| hash[key] = {} }
  end

  def add_transition(from, with, to)
    @graph[from][with] ||= []
    @graph[from][with] << to
  end

  def to_dot
    DotPresenter.new(self).output
  end

  def self.from_regular_expression(regexp, visitor)
    visitor.visit regexp
  end

  def check_word word
    return false unless deterministic?

    current_node = initial_state
    word.each_char do |char|
      to_nodes = graph[current_node][char]
      return false if to_nodes.nil?
      current_node = to_nodes.first
    end

    final_states.include? current_node
  end

  def get_complement
    make_complete!

    complement = Automaton.new
    complement.alphabet = alphabet
    complement.states = states
    complement.graph = graph
    complement.initial_state = initial_state
    complement.final_states = states - final_states

    complement
  end

  def make_complete!
    return if complete?

    terminal = "qt"
    states << terminal
    states.each do |state|
      (alphabet - graph[state].keys).each do |label|
        add_transition(state, label, terminal)
      end
    end
  end

  def complete?
    states.all? do |state|
      graph[state].keys.length == alphabet.length
    end
  end

  def deterministic?
    labels = graph.values.collect {|node_transitions| node_transitions.keys}
    has_lambda = labels.flatten.include? ""

    only_one_to_node = graph.values.all? do |node_transitions|
      node_transitions.values.all? {|transitions| transitions.length <= 1}
    end

    !has_lambda && only_one_to_node
  end
end
