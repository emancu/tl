class FilePresenter
  attr_reader :output

  def initialize(automaton)
    @output = automaton.states.join("\t") + "\n"
    @output << automaton.alphabet.join("\t") + "\n"
    @output << automaton.initial_state + "\n"
    @output << automaton.final_states.join("\t") + "\n"

    automaton.graph.each do |state, transitions|
      transitions.each do |label, dest|
        dest.each do |d|
          @output << "#{state}\t#{label}\t#{d}\n"
        end
      end
    end
  end
end
