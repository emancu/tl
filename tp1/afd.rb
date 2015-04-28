#!/usr/bin/env ruby
#
require_relative "lib/automaton"
require_relative "lib/regular_expression"
require_relative "lib/thompson_construction_visitor"

def match_params?(params, expected_params, expected_size = nil)
  size_ok = params.size == (expected_size || expected_params.keys.size * 2)
  size_ok && expected_params.all? do |position, value|
    params[position] == value
  end
end

def write_dot_file(file, automaton)
  File.write file, automaton.to_dot
end

params = ARGV[0..-1]
if match_params?(params, {0 => "-leng", 2 => "-aut"})
  regexp = RegularExpression.from_file params[1]
  automaton = regexp.to_automaton
  minimum = automaton.minimize

  write_dot_file params[3], minimum
elsif match_params?(params, {0 => "-aut"}, 3)
  automaton = Automaton.from_file params[1]

  puts automaton.check_word(params[2]).to_s.upcase
elsif match_params?(params, {0 => "-aut", 2 => "-dot"})
  automaton = Automaton.from_file params[1]

  write_dot_file params[3], automaton
elsif match_params?(params, {0 => "-intersec", 1 => "-aut1", 3 => "-aut2", 5 => "-aut"}, 7)
  automaton = Automaton.from_file params[2]
  automaton2 = Automaton.from_file params[4]
  intersection = automaton.intersect automaton2

  write_dot_file params[6], intersection
elsif match_params?(params, {0 => "-complemento", 1 => "-aut1", 3 => "-aut"}, 5)
  automaton = Automaton.from_file params[2]
  complement = automaton.complement

  write_dot_file params[4], complemento
elsif match_params?(params, {0 => "-equival", 1 => "-aut1", 3 => "-aut2"}, 5)
  automaton = Automaton.from_file params[2]
  automaton.rename_nodes
  automaton2 = Automaton.from_file params[4]

  automaton_complement = automaton.complement
  automaton2_complement = automaton2.complement

  intersection_1 = automaton.intersect automaton2_complement
  intersection_1.rename_nodes
  intersection_2 = automaton_complement.intersect automaton2
  intersection_2.rename_nodes

  union = intersection_1.get_union_with(intersection_2)
  det_union = union.get_deterministic

  puts det_union.empty?.to_s.upcase
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
