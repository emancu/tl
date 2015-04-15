require_relative 'automaton'

class AutomatonHelper
  def self.read_from_file(file, automaton)
    f = File.open(file)

    automaton.states = f.readline.tr("\n","").split(/\t/)
    automaton.alphabet = f.readline.tr("\n","").split(/\t/)
    automaton.initial_state = f.readline.strip
    automaton.final_states = f.readline.strip.split(/\t/)

    f.each do |line|
      automaton.add_transition *line.strip.split(/\t/)
    end

    f.close

    require 'pry'; binding.pry
    automaton
  end
end
