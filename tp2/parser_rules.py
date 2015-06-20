from lexer_rules import tokens

from expressions import Initial, Tempo, Compass, Number, Vars, Node


def p_expression_initial(subexpressions):
  'expression : te co vars'
  subexpressions[0] = Initial(subexpressions[1:])

def p_expression_tempo(subexpressions):
  'te : TEMPO FIGURE NUMBER'
  subexpressions[0] = Node('tempo', subexpressions[2:])
  #subexpressions[0] = Tempo(subexpressions[2], subexpressions[3])

def p_expression_compass(subexpressions):
  'co : COMPASS_V NUMBER DIV NUMBER'
  subexpressions[0] = Compass(subexpressions[2], subexpressions[4])

def p_vars(subexpressions):
  'vars : CONST NAME EQUAL cons_val SEMICOLON'

  import pdb; pdb.set_trace()
  subexpressions[0] = Vars(subexpressions[2::2])

def p_vars_empty(subexpressions):
  'vars :'

  subexpressions[0] = Number('819247')

def p_cons_val(s):
  'cons_val : NUMBER'
  '         | NAME'
  s[0] = Number(s[1])


def p_vars_lambda(subexpressions):
  'vars : CONST NAME EQUAL cons_val'

def p_term_times(subexpressions):
  'term : term TIMES factor'
  subexpressions[0] = Multiplication(subexpressions[1], subexpressions[3])


def p_term_factor(subexpressions):
  'term : factor'
  subexpressions[0] = subexpressions[1]


def p_factor_number(subexpressions):
  'factor : NUMBER'
  subexpressions[0] = Number(subexpressions[1])


def p_factor_expression(subexpressions):
  'factor : LPAREN expression RPAREN'
  subexpressions[0] = subexpressions[2]

def p_error(subexpressions):
  import pdb; pdb.set_trace()
  raise Exception("Syntax error.")
