#!/usr/bin/env ruby
#
require_relative "lib/automaton"
require_relative "regular_expression"
require_relative "thompson_contruction_visitor"

def match_params?(params, expected_params, expected_size = nil)
  size_ok = params.size == (expected_size || expected_params.keys.size * 2)
  size_ok && expected_params.all? do |position, value|
    params[position] == value
  end
end

params = ARGV[0..-1]
if match_params?(params, {0 => "-leng", 2 => "-aut"})
  regexp = RegularExpression.from_file params[1]
  automaton = Automaton.from_regular_expression regexp, ThompsonContructionVisitor
  minimum = automaton.get_minimum
  File.write(params[3], minimum.to_dot)
elsif match_params?(params, {0 => "-aut"}, 3)
  automaton = Automaton.from_file params[1]
  puts automaton.check_word(params[2]).to_s.upcase
elsif match_params?(params, {0 => "-aut", 2 => "-dot"})
  automaton = Automaton.from_file params[1]
  File.write(params[3], automaton.to_dot)
elsif match_params?(params, {0 => "-intersec", 1 => "-aut1", 3 => "-aut2", 5 => "-aut"}, 7)
  automaton = Automaton.from_file params[2]
  automaton2 = Automaton.from_file params[4]
  intersection = automaton.intersection_with(automaton2)
  File.write(params[6], intersection.to_dot)
elsif match_params?(params, {0 => "-complemento", 1 => "-aut1", 3 => "-aut"}, 5)
  automaton = Automaton.from_file params[2]
  complement = automaton.get_complement
  File.write(params[4], complement.to_dot)
elsif match_params?(params, {0 => "-equival", 1 => "-aut1", 3 => "-aut2"}, 5)
  puts "son equivalentes"
else
  puts <<-EOS
    Parametros invalidos.
    Uso:

    "afd -leng <archivo_regex> -aut <archivo_automata>"
    "afd -aut <archivo_automata> <cadena>"
    "afd -aut <archivo_automata> -dot <archivo_dot>"
    "afd -intersec -aut1 <archivo_automata> -aut2 <archivo_automata> -aut <archivo_automata>"
    "afd -complemento -aut1 <archivo_automata> -aut <archivo_automata>"
    "afd -equival -aut1 <archivo_automata> -aut2 <archivo_automata>"
  EOS

  exit false
end
