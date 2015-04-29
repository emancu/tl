#!/usr/bin/env ruby
#
require_relative 'lib/main'

def match_params?(params, expected_params, expected_size = nil)
  size_ok = params.size == (expected_size || expected_params.keys.size * 2)
  size_ok && expected_params.all? do |position, value|
    params[position] == value
  end
end

params = ARGV[0..-1]

if match_params?(params, 0 => '-leng', 2 => '-aut')
  Main.minimize_from_regexp params[1], params[3]
elsif match_params?(params, { 0 => '-aut' }, 3)
  Main.check_string params[1], params[2]
elsif match_params?(params, 0 => '-aut', 2 => '-dot')
  Main.export_to_dot params[1], params[3]
elsif match_params?(params, { 0 => '-intersec', 1 => '-aut1', 3 => '-aut2', 5 => '-aut' }, 7)
  Main.minimum_intersection params[2], params[4], params[6]
elsif match_params?(params, { 0 => '-complemento', 1 => '-aut1', 3 => '-aut' }, 5)
  Main.minimum_complement params[2], params[4]
elsif match_params?(params, { 0 => '-equival', 1 => '-aut1', 3 => '-aut2' }, 5)
  Main.equivalent params[2], params[4]
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
