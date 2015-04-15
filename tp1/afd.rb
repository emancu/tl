#!/usr/bin/env ruby
#
require_relative "lib/automaton"

def match_params?(params, expected_params, expected_size = nil)
  size_ok = params.size == (expected_size || expected_params.keys.size * 2)
  size_ok && expected_params.all? do |position, value|
    params[position] == value
  end
end

params = ARGV[0..-1]
if match_params?(params, {0 => "-leng", 2 => "-aut"})
  puts "afd minimo"

elsif match_params?(params, {0 => "-aut"}, 3)
  puts "pertenece cadena"
elsif match_params?(params, {0 => "-aut", 2 => "-dot"})
  puts "grafo: "
  Automaton.from_file params[1]
elsif match_params?(params, {0 => "-intersec", 1 => "-aut", 3 => "-aut2", 5 => "-aut"}, 7)
  puts "interseccion"
elsif match_params?(params, {0 => "-complemento", 1 => "-aut1", 3 => "-aut"}, 5)
  puts "complemento"
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
