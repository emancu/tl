require_relative 'dot_presenter'
require_relative 'file_presenter'

class Automaton
  attr_accessor :graph, :states, :alphabet, :initial_state, :final_states

  @@name = 'a'

  def self.from_file(file)
    automaton = new
    f = File.open(file)

    automaton.states = f.readline.strip.split(/\t/)
    automaton.alphabet = f.readline.strip.split(/\t/)
    automaton.initial_state = f.readline.strip
    automaton.final_states = f.readline.strip.split(/\t/)

    f.each do |line|
      automaton.add_transition(*line.strip.split(/\t/))
    end

    f.close

    automaton
  end

  def initialize
    @prefix = 'a'
    @states = []
    @alphabet = []
    @final_states = []
    @graph = Hash.new { |hash, key| hash[key] = {} }
  end

  def add_transition(from, with, to)
    @graph[from][with] ||= []
    @graph[from][with] << to
    @graph[from][with].uniq!
  end

  def to_dot
    DotPresenter.new(self).output
  end

  def to_file
    FilePresenter.new(self).output
  end

  def check_word(word)
    return false unless deterministic?

    current_node = initial_state
    word.each_char do |char|
      to_nodes = graph[current_node][char]
      return false if to_nodes.nil?
      current_node = to_nodes.first
    end

    final_states.include? current_node
  end

  def intersect(automaton)
    automaton.rename_states

    intersection = Automaton.new
    intersection.alphabet = alphabet & automaton.alphabet
    intersection.initial_state = "#{initial_state}-#{automaton.initial_state}"
    intersection.states = merge_states states, automaton.states
    intersection.final_states = merge_states final_states, automaton.final_states

    intersection.states.each do |from_state|
      from_1, from_2 = from_state.split('-')

      intersection.states.each do |to_state|
        to_1, to_2 = to_state.split('-')

        intersection.alphabet.each do |char|
          if transition?(from_1, to_1, char) && automaton.transition?(from_2, to_2, char)
            intersection.add_transition(from_state, char, to_state)
          end
        end
      end
    end

    intersection.rename_states
    intersection.minimize
  end

  # http://en.wikipedia.org/wiki/DFA_minimization#Brzozowski.27s_algorithm
  def minimize
    det = get_deterministic

    rev = det.brzozowski_reverse
    minimum = rev.brzozowski_reverse

    minimum.remove_terminal
  end

  def remove_terminal
    terminal_states = (states - final_states).select do |state|
      graph[state].all? { |_, values| values == [state] }
    end

    terminal_states.each do |state|
      states.delete state
      graph.delete state

      graph.each do |_, node_transitions|
        node_transitions.each { |_, nodes| nodes.delete state }
      end
    end

    self
  end

  # The reverting step in Brzozowski's Algorithm does not introduce a new virtual
  # starting state that leads to the old accepting states via lambda-transitions.
  # Instead it allows multiple starting states, which is no big problem,
  # if you construct the product-automaton anyway right after the reversion.
  def brzozowski_reverse
    brzozowski = Automaton.new
    brzozowski.alphabet = alphabet.dup
    brzozowski.states = states.dup
    brzozowski.final_states = [initial_state]

    graph.each do |node_from, node_transitions|
      node_transitions.each do |char, nodes|
        nodes.each do |node_to|
          brzozowski.add_transition(node_to, char, node_from)
        end
      end
    end

    initial_closure = closure_lambda(final_states)
    brzozowski.get_deterministic initial_closure
  end

  def complement
    make_complete!

    complemented = Automaton.new
    complemented.alphabet = alphabet.dup
    complemented.states = states.dup
    complemented.graph = deep_dup graph
    complemented.initial_state = initial_state.dup
    complemented.final_states = states - final_states

    complemented
  end

  def get_union_with(automaton_2)
    automaton_2.rename_states

    union = Automaton.new
    union.alphabet = (alphabet + automaton_2.alphabet).uniq
    is, fs = "#{@@name}i", "#{@@name}f"
    @@name.next!
    union.states = ([is, fs] + (states) + automaton_2.states)
    union.graph = graph.merge automaton_2.graph
    union.graph.default = {}
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

    terminal = 'qt'
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
      unless graph[current_node].nil?
        alphabet.each do |char|
          aux += Array(graph[current_node][char])
        end
      end
      aux -= visited

      (to_review += aux).uniq!
      (reachable += aux).uniq!
    end

    (reachable.uniq & final_states).empty?
  end

  def deterministic?
    labels = graph.values.map(&:keys)
    has_lambda = labels.flatten.include? ''

    only_one_to_node = graph.values.all? do |node_transitions|
      node_transitions.values.all? { |transitions| transitions.length <= 1 }
    end

    !has_lambda && only_one_to_node
  end

  def get_deterministic(initial = nil)
    initial ||= closure_lambda [initial_state]
    is = initial.sort!.join('-')

    automaton = Automaton.new
    automaton.alphabet = alphabet
    automaton.states << is
    automaton.initial_state = is
    automaton.final_states << is if (initial & final_states).any?

    to_review = [is]
    until to_review.empty?
      current_state = to_review.shift
      current_nodes = current_state.split('-')

      alphabet.each do |char|
        new_nodes = closure(current_nodes, char)
        new_state = new_nodes.sort.join('-')

        unless automaton.states.include? new_state
          automaton.states << new_state
          automaton.final_states << new_state if (new_state.split('-') & final_states).any?
          to_review << new_state
        end

        automaton.add_transition(current_state, char, new_state)
      end
    end

    automaton.rename_states
  end

  def rename_states(prefix = @prefix)
    new_names = {}

    states.map! do |s|
      new_names[s] ||= "#{prefix}#{new_names.keys.size}"
    end

    self.initial_state = new_names[initial_state]
    final_states.map! { |s| new_names[s] }

    # Rename graph transitions
    new_graph = Hash.new { |hash, key| hash[key] = {} }

    graph.map do |from, with|
      from_key = new_names[from]
      with.map do |w, tos|
        new_graph[from_key][w] = tos.map { |a| new_names[a] }
      end
    end

    @prefix.next! if prefix == @prefix
    self.graph = new_graph

    self
  end

  def closure(nodes, char)
    result = bfs nodes.dup, char

    closure_lambda result
  end

  def closure_lambda(nodes)
    nodes.concat(bfs(nodes.dup, '')).uniq
  end

  protected

  def transition?(from, to, with)
    Array(graph[from][with]).include? to
  end

  private

  def merge_states(states_a, states_b)
    states_a.product(states_b).map { |s| s.join('-') }
  end

  def bfs(to_review, char)
    result = []
    visited = []

    until to_review.empty?
      current_node = to_review.shift
      visited << current_node

      to_review = to_review.uniq - visited
      aux = Array(graph[current_node][char])

      to_review += aux if char == ''
      result += aux
    end

    result.uniq
  end
end
