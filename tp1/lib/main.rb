require_relative 'automaton'
require_relative 'regular_expression'
require_relative 'thompson_construction_visitor'

class Main

  def self.minimize_from_regexp(regexp_file, output_file)
    regexp = RegularExpression.from_file regexp_file
    automaton = regexp.to_automaton
    minimum = automaton.minimize

    write_automata_file output_file, minimum
  end

  def self.check_string(deterministic_file, string)
    automaton = Automaton.from_file deterministic_file

    automaton.check_word(string)
  end

  def self.export_to_dot(deterministic_file, output_file)
    automaton = Automaton.from_file deterministic_file

    write_dot_file output_file, automaton
  end

  def self.minimum_intersection(file1, file2, output_file)
    automaton = Automaton.from_file file1
    automaton2 = Automaton.from_file file2
    intersection = automaton.intersect automaton2

    write_automata_file output_file, intersection
  end

  def self.minimum_complement(deterministic_file, output_file)
    automaton = Automaton.from_file deterministic_file
    complement = automaton.complement

    write_automata_file output_file, complement.minimize
  end

  def self.equivalent(aut1, aut2)
    automaton = Automaton.from_file aut1
    automaton2 = Automaton.from_file aut2

    automaton.equivalent? automaton2
  end

  private

  def self.write_dot_file(file, automaton)
    File.write file, automaton.to_dot
  end

  def self.write_automata_file(file, automaton)
    File.write file, automaton.to_file
  end
end
