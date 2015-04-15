class DotPresenter
  attr_reader :output

  def initialize(automaton)
    @automaton = automaton
    @output = 'digraph {'
    @output << 'rankdir=LR;'
    @output << "node [shape = none, label = ""]; qd;"
    @output << 'node [label = "\N", width= 0.5, height = 0.5];'

    @automaton.final_states.each do |state|
      @output << "node [shape = doublecircle]; #{state};"
    end

    @output << 'node [shape = circle];'
    @output << "qd -> #{@automaton.initial_state}"

    graph = Hash.new { |hash, key| hash[key] = {} }
    @automaton.states.each do |state|
      @automaton.graph[state].each do |k,v|
        v.each do |s|
          graph[state][s] ||= []; graph[state][s] << k
        end
      end
    end

    graph.each do |state, transitions|
      transitions.each do |dest, label|
        @output << "#{state} -> #{dest} [label=\"#{label.join(', ')}\"]"
      end
    end

    @output << '}'
  end
end
