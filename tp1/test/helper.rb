$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))

require 'minitest/autorun'
require 'automaton'
require 'regular_expression'
require 'thompson_construction_visitor'

def deny(condition, message = 'Expected condition to be unsatisfied')
  assert !condition, message
end
