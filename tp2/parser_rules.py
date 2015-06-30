from lexer_rules import tokens

from expressions import Initial, Node, Element, Number

class SemanticException(Exception):
    pass

# dictionary of names
names = {}

def p_expression_initial(subexpressions):
  'expression : te co vars'
  subexpressions[0] = Node('S', subexpressions[1:])

def p_expression_tempo(subexpressions):
  'te : TEMPO FIGURE NUMBER'
  subexpressions[0] = Node('te', subexpressions[1:])

def p_expression_compass(subexpressions):
  'co : COMPASS_V NUMBER DIV NUMBER'
  subexpressions[0] = Node('co', subexpressions[1:])

def p_vars(subexpressions):
  'vars : vars CONST NAME EQUAL cons_val SEMICOLON'
  name = subexpressions[3]
  cons_val = subexpressions[5]
  if (cons_val.__class__ == Number):
    names[name] = cons_val.value
  elif cons_val.value in names:
    names[name] = names[cons_val.value]
  else:
    raise SemanticException("const '" + cons_val.value + "' is undefined")

  subexpressions[0] = Node('vars', subexpressions[1:])

def p_vars_empty(subexpressions):
  'vars :'

def p_cons_val_number(s):
  'cons_val : NUMBER'
  s[0] = Number(s[1])

def p_cons_val_name(s):
  'cons_val : NAME'
  s[0] = Element(s[1])

def p_error(subexpressions):
  import pdb; pdb.set_trace()
  raise Exception("Syntax error.")
