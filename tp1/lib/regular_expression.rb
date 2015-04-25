class RegularExpression
  attr_accessor :values

  SPECIAL = /{(CONCAT|STAR|PLUS|OPT|OR)}(\d)?/

  def self.from_file(file_path)
    file = File.open file_path

    current_re = read_file(file, 1).first

    file.close

    current_re
  end

  def self.read_file(file, amount)
    amount ||= '1'
    amount = amount.to_i
    values = []

    amount.times do |x|
      line = file.readline

      matches = line.match SPECIAL

      if matches
        values << factory(matches[1]).new_from_file(file, matches[-1])
      else
        values << SimpleRegularExpression.new(line)
      end
    end

    values
  end

  def self.new_from_file(file, amount)
    object = new read_file(file, amount)
  end

  def initialize(values)
    @values = values
  end

  def self.factory(type)
    Object.const_get(:"#{type.capitalize}RegularExpression")
  end
end

class ConcatRegularExpression < RegularExpression
  def to_s
    @values.map(&:to_s).join
  end

  def accept_visitor(visitor)
    visitor.visit_concat self
  end
end

class StarRegularExpression < RegularExpression
  def to_s
    str = @values.first.to_s
    str = "(#{str})" unless str.match /^\(.*\)$/
    str + '*'
  end

  def accept_visitor(visitor)
    visitor.visit_star self
  end
end

class OrRegularExpression < RegularExpression
  def to_s
    "(#{@values.map(&:to_s).join('|')})"
  end

  def accept_visitor(visitor)
    visitor.visit_or self
  end
end

class SimpleRegularExpression < RegularExpression
  attr_accessor :char

  def initialize(line)
    require 'pry'; binding.pry
    @char = line.strip
  end

  def to_s
    @char
  end

  def accept_visitor(visitor)
    visitor.visit_simple self
  end
end

class PlusRegularExpression < RegularExpression
  def self.new_from_file(file, amount)
    star = StarRegularExpression.new_from_file file, amount

    ConcatRegularExpression.new [star.values.first, star]
  end
end

class OptRegularExpression < RegularExpression
  def self.new_from_file(file, amount)
    lambda_expression = LambdaRegularExpression.new

    or_expression = OrRegularExpression.new_from_file file, amount
    or_expression.values << lambda_expression

    or_expression
  end
end

class LambdaRegularExpression < SimpleRegularExpression
  def initialize
    super('')
  end

  def accept_visitor(visitor)
    visitor.visit_lambda self
  end
end
