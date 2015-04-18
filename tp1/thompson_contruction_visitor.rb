require_relative './lib/automaton'

class ThompsonContructionVisitor
  attr_accessor :order

  def self.visit(regexp)
    regexp.accept_visitor new
  end

  def initialize
    @order = 1
  end

  def new_automaton(initial_state = "q#{order}", final_states = ["f#{order}"])
    automaton = Automaton.new
    automaton.initial_state = initial_state
    automaton.final_states = final_states
    automaton.states = automaton.final_states + [automaton.initial_state]

    @order += 1

    automaton
  end

  def visit_lambda(lambda_expression)
    a = new_automaton
    a.add_transition a.initial_state, '', a.final_states.first

    a
  end

  def visit_simple(simple)
    a = new_automaton
    a.add_transition a.initial_state, simple.char, a.final_states.first
    a.alphabet << simple.char

    a
  end

  def visit_or(or_expression)
    automaton = new_automaton
    is = automaton.initial_state
    fs = automaton.final_states.first

    to_join = []

    # Create automatom for each value
    or_expression.values.each do |regexp|
      or_automatom = regexp.accept_visitor self
      to_join << or_automatom
      union automaton, or_automatom
    end

    # Add lambda to each initial state
    to_join.each do |to_join_automatom|
      automaton.add_transition is, '', to_join_automatom.initial_state

    # Add lambda from each final of each automatom to result final state
      to_join_automatom.final_states.each do |final_state|
        automaton.add_transition final_state, '', fs
      end
    end

    automaton
  end


  def visit_concat(concat)
    to_join = []

    # Create automatom for each value
    concat.values.each do |regexp|
      regexp.accept_visitor(self).tap do |aut|
        to_join << aut
      end
    end

    automaton = new_automaton(to_join.first.initial_state, to_join.last.final_states)

    finals = []
    to_join.each do |aut|
      union automaton, aut

      finals.each do |f|
        automaton.add_transition f, '', aut.initial_state
      end

      finals = aut.final_states
    end

    automaton
  end

  def visit_star(star)
    aut = star.values.first.accept_visitor self
    automaton = new_automaton
    is = automaton.initial_state
    fs = automaton.final_states.first

    union automaton, aut

    automaton.add_transition is, '', fs
    automaton.add_transition is, '', aut.initial_state

    aut.final_states.each do |star_fs|
      automaton.add_transition star_fs, '', fs
      automaton.add_transition star_fs, '', aut.initial_state
    end

    automaton
  end

  def union(dst, src)
    (dst.alphabet += src.alphabet).uniq!
    (dst.states += src.states).uniq!
    require 'pry'; binding.pry
    dst.graph.merge! src.graph
  end

end

##
# automaton.states = f.readline.tr("\n","").split(/\t/)
# automaton.alphabet = f.readline.tr("\n","").split(/\t/)
# automaton.initial_state = f.readline.strip
# automaton.final_states = f.readline.strip.split(/\t/)
# automaton.add_transition *line.strip.split(/\t/)
##
