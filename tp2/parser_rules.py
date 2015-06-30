from lexer_rules import tokens

from expressions import Initial, Node, Element, Number

class SemanticException(Exception):
    pass

# dictionary of names
names = {}

def p_expression_initial(subexpressions):
  'expression : te co vars voices'
  subexpressions[0] = Node('S', subexpressions[1:])

def p_expression_tempo(subexpressions):
  'te : TEMPO FIGURE NUMBER'
  subexpressions[0] = Node('te', subexpressions[1:])

def p_expression_compass_v(subexpressions):
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

def p_expression_voices(s):
  'voices : voice voices'
  s[0] = Node('voices', s[1:])

def p_expression_voices_empty(s):
  'voices :'

def p_expression_voice(s):
  'voice : VOICE LPAREN cons_val RPAREN LCURLYBRACKET voice_content RCURLYBRACKET'
  cons_val = s[3]
  if (cons_val.__class__ == Element and not(cons_val.value in names)):
    raise SemanticException("const '" + cons_val.value + "' is undefined")
  s[0] = Node('voice', s[1:])

def p_expression_voice_content(s):
  'voice_content : compass voice_content'
  s[0] = Node('voice_content', s[1:])

def p_expression_voice_content_empty(s):
  'voice_content :'

def p_expression_compass(s):
  'compass : COMPASS LCURLYBRACKET compass_content RCURLYBRACKET'
  s[0] = Node('compass', s[1:])

def p_expression_compass_empty(s):
  'compass :'

def p_expression_voice_compass_content_note(s):
  'compass_content : note compass_content '
  s[0] = Node('compass_content', s[1:])

def p_expression_compass_content_empty(s):
  'compass_content :'

def p_expression_voice_compass_content_silence(s):
  'compass_content : silence compass_content'
  s[0] = Node('compass_content', s[1:])

def p_expression_note(s):
  'note : NOTE LPAREN NOTE_ID COMMA cons_val COMMA figure_duration RPAREN SEMICOLON'
  s[0] = Node('note', s[1:])

def p_expression_silence(s):
  'silence : SILENCE LPAREN figure_duration RPAREN SEMICOLON'
  s[0] = Node('silence', s[1:])

def p_expression_figure(s):
  'figure_duration : FIGURE'
  s[0] = Element(s[1])

def p_expression_duration(s):
  'figure_duration : DURATION'
  s[0] = Element(s[1])

def p_error(subexpressions):
  import pdb; pdb.set_trace()
  raise Exception("Syntax error.")
