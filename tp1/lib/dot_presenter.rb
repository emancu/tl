class DotPresenter
  attr_reader :output

  def initialize(automaton)
    @automaton = automaton
    @output = "strict digraph {\n"
    @output << "\trankdir=LR;\n"
    @output << "\tnode [shape = none, label = \"\"]; qd;\n"
    @output << "\tnode [label = \"\\N\", width= 0.5, height = 0.5];\n"

    @automaton.final_states.each do |state|
      @output << "\tnode [shape = doublecircle]; #{state};\n"
    end

    @output << "\tnode [shape = circle];\n"
    @output << "\tqd -> #{@automaton.initial_state}\n"

    graph = Hash.new { |hash, key| hash[key] = {} }
    @automaton.states.each do |state|
      @automaton.graph[state].to_h.each do |k, v|
        v.each do |s|
          graph[state][s] ||= []
          graph[state][s] << k
        end
      end
    end

    graph.each do |state, transitions|
      transitions.each do |dest, label|
        @output << "\t#{state} -> #{dest} [label=\"#{label.join(', ')}\"]\n"
      end
    end

    @output << '}'
  end
end
