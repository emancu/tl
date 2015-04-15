require_relative 'automaton_helper'
require_relative 'dot_presenter'

class Automaton
  attr_accessor :graph, :states, :alphabet, :initial_state, :final_states

  def self.from_file(file)
    AutomatonHelper.read_from_file file, new
  end

  def initialize
    @graph = Hash.new { |hash, key| hash[key] = {} }
  end

  def add_transition(from, with, to)
    @graph[from][with] ||= []
    @graph[from][with] << to
  end

  def to_dot
    DotPresenter.new(self).output
  end
end
