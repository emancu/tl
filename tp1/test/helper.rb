$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))

require 'minitest/autorun'
require 'main'

def deny(condition, message = 'Expected condition to be unsatisfied')
  assert !condition, message
end

# Returns an Automaton which accepts `ab`
def load_afd
  @afd ||= Automaton.new.tap do |automaton|
    automaton.states = %w(q0 q1 q2)
    automaton.alphabet = %w(a b)
    automaton.initial_state = 'q0'
    automaton.final_states = ['q2']
    automaton.add_transition('q0', 'a', 'q1')
    automaton.add_transition('q1', 'b', 'q2')
  end
end

# Returns an Automaton Non Deterministic which accepts `ab, a`
def load_afnd
  @afnd ||= Automaton.new.tap do |automaton|
    automaton.states = %w(q0 q1 q2)
    automaton.alphabet = %w(a b)
    automaton.initial_state = 'q0'
    automaton.final_states = ['q2']
    automaton.add_transition('q0', 'a', 'q1')
    automaton.add_transition('q0', 'a', 'q2')
    automaton.add_transition('q1', 'b', 'q2')
  end
end

# Returns an Automaton Non Deterministic which accepts `ab, a, aaa...a, aaa...ab`
def load_cycle
  @cycle ||= Automaton.new.tap do |automaton|
    automaton.states = %w(q0 q1 q2)
    automaton.alphabet = %w(a b)
    automaton.initial_state = 'q0'
    automaton.final_states = ['q2']
    automaton.add_transition('q0', 'a', 'q0')
    automaton.add_transition('q0', 'a', 'q1')
    automaton.add_transition('q0', 'a', 'q2')
    automaton.add_transition('q0', 'b', 'q2')
  end
end

def load_practica
  Automaton.new.tap do |automaton|
    automaton.states = %w(q0 q1 q2 q3 q4)
    automaton.alphabet = %w(0 1)
    automaton.initial_state = 'q0'
    automaton.final_states = ['q3']
    automaton.add_transition('q0', '', 'q1')
    automaton.add_transition('q0', '', 'q2')
    automaton.add_transition('q1', '0', 'q1')
    automaton.add_transition('q1', '1', 'q1')
    automaton.add_transition('q1', '1', 'q3')
    automaton.add_transition('q2', '0', 'q2')
    automaton.add_transition('q2', '1', 'q4')
    automaton.add_transition('q2', '', 'q3')
    automaton.add_transition('q4', '0', 'q4')
    automaton.add_transition('q4', '1', 'q2')
  end
end
