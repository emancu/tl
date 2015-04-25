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
    @graph[from] ||= {}
    @graph[from][with] ||= []
    @graph[from][with] << to
    @graph[from][with].uniq!
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


  def get_intersection_with(automaton)
    automaton.rename_nodes
    intersection = Automaton.new
    intersection.alphabet = self.alphabet & automaton.alphabet
    intersection.states = self.states.product automaton.states
    intersection.states.map!{|states| states.join("-")}
    intersection.initial_state = "#{initial_state}-#{automaton.initial_state}"

    intersection.states.each do |from_state|
      from_1, from_2 = from_state.split("-")
      intersection.final_states << from_state if final_states.include?(from_1) && automaton.final_states.include?(from_2)
      intersection.states.each do |to_state|
        to_1, to_2 = to_state.split("-")
        intersection.alphabet.each do |char|
          if (transition_from_to_with?(from_1, to_1, char) && automaton.transition_from_to_with?(from_2, to_2, char))
            intersection.add_transition(from_state, char, to_state)
          end
        end
      end
    end

    intersection.rename_nodes
    intersection.get_minimum
  end

  #private
  def transition_from_to_with?(from, to, with)
    graph[from] && !graph[from][with].nil? && graph[from][with].include?(to)
  end

  # http://en.wikipedia.org/wiki/DFA_minimization#Brzozowski.27s_algorithm
  def get_minimum
    det = get_deterministic

    rev = det.get_reverse
    det2 = rev.get_deterministic
    rev2 = det2.get_reverse

    minimum = rev2.get_deterministic
    minimum.remove_terminal
  end

  # Ask if this is neccessary, improve code!
  def remove_terminal
    states.each do |state|
      final = !(final_states.include?(state)) && graph[state].all? {|key, values| values == [state]}
      if final
        self.states.reject! { |node| node == state }
        self.graph.reject! { |node| node == state }
        graph.each do |node, node_transitions|
          node_transitions.each do |char, nodes|
            nodes.reject! { |node| node == state }
          end
        end
      end
    end

    self
  end

  def get_reverse
    reverse = Automaton.new
    reverse.alphabet = alphabet
    reverse.states = states
    reverse.initial_state = "i1"
    reverse.final_states = [initial_state]

    graph.each do |node_from, node_transitions|
      node_transitions.each do |char, nodes|
        nodes.each do |node_to|
          reverse.add_transition(node_to, char, node_from)
        end
      end
    end

    final_states.each do |final|
      reverse.add_transition(reverse.initial_state, '', final)
    end

    reverse
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

  def get_union_with(automaton_2)
    automaton_2.rename_nodes

    union = Automaton.new
    union.alphabet = (alphabet + automaton_2.alphabet).uniq
    is, fs = "is", "fs"
    union.states = ([is,fs] + (states) + automaton_2.states)
    union.graph = graph.merge automaton_2.graph
    union.initial_state = is
    union.final_states = [fs]

    final_states.each do |final|
      union.add_transition(final, '', fs)
    end
    automaton_2.final_states.each do |final|
      union.add_transition(final, '', fs)
    end

    union.add_transition(is, '', initial_state)
    union.add_transition(is, '', automaton_2.initial_state)

    union
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

  def empty?
    reachable = [initial_state]
    to_review = [initial_state]
    visited = []

    until to_review.empty?
      current_node = to_review.shift
      visited << current_node

      to_review = to_review.uniq - visited
      aux = []
      if !graph[current_node].nil?
        alphabet.each do |char|
          aux += Array(graph[current_node][char])
        end
      end

      to_review += aux
      reachable += aux
    end

    (reachable.uniq & final_states).empty?
  end

  def deterministic?
    labels = graph.values.collect {|node_transitions| node_transitions.keys}
    has_lambda = labels.flatten.include? ""

    only_one_to_node = graph.values.all? do |node_transitions|
      node_transitions.values.all? {|transitions| transitions.length <= 1}
    end

    !has_lambda && only_one_to_node
  end

  def get_deterministic
    initial = self.closure_lambda([self.initial_state])
    is = initial.sort.join('-')

    automaton = Automaton.new
    automaton.alphabet = alphabet
    automaton.states << is
    automaton.initial_state = is
    automaton.final_states << is if (is.split("-") & final_states).any?

    current_state = is
    to_review = [is]
    until to_review.empty?
      current_state = to_review.shift
      current_nodes = current_state.split("-")
      alphabet.each do |char|
        new_nodes = closure(current_nodes, char)
        new_state = new_nodes.sort.join('-')
        unless automaton.states.include? new_state
          automaton.states << new_state
          automaton.final_states << new_state if (new_state.split("-") & final_states).any?
          to_review << new_state
        end
        automaton.add_transition(current_state, char, new_state)
      end
    end

    automaton.rename_nodes
  end

  def rename_nodes
    new_names = {}
    states.map! do |s|
      new_names[s] ||= "t#{new_names.keys.size}"
    end

    self.initial_state = new_names[initial_state]
    final_states.map! {|s| new_names[s]}

    self.graph = Hash[graph.map {|k, v| [new_names[k], Hash[v.map {|k2, v2| [k2, v2.map {|a| new_names[a]}] }]  ] }]

    self
  end

  def closure(nodes, char)
    result = []
    to_review = nodes.dup
    visited = []

    until to_review.empty?
      current_node = to_review.shift
      visited << current_node

      to_review = to_review.uniq - visited

      if graph[current_node].nil?
        aux = []
      else
        aux = Array(graph[current_node][char])
      end

      result += aux
    end

    result.uniq!

    result = closure_lambda result

    result
  end

  def closure_lambda(nodes)
    result = nodes
    to_review = nodes.dup
    visited = []

    until to_review.empty?
      current_node = to_review.shift
      visited << current_node

      to_review = to_review.uniq - visited
      if graph[current_node].nil?
        aux = []
      else
        aux = Array(graph[current_node][''])
      end

      to_review += aux
      result += aux
    end

    result.uniq
  end

  def self.afnd
    automaton = Automaton.new
    automaton.initial_state = "q0"
    automaton.final_states = ["q3"]
    automaton.alphabet = ["0", "1"]
    automaton.states = ["q0", "q1", "q2", "q3", "q4"]
    automaton.add_transition("q0", '', "q1")
    automaton.add_transition("q0", '', "q2")
    automaton.add_transition("q1", '0', "q1")
    automaton.add_transition("q1", '1', "q1")
    automaton.add_transition("q1", '1', "q3")
    automaton.add_transition("q2", '0', "q2")
    automaton.add_transition("q2", '1', "q4")
    automaton.add_transition("q2", '', "q3")
    automaton.add_transition("q4", '0', "q4")
    automaton.add_transition("q4", '1', "q2")

    automaton
  end
end
