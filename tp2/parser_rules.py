from __future__ import division
from lexer_rules import tokens
from expressions import Initial, Node, Element, Number

class SemanticException(Exception):
    pass

names = {}
util_vars = {}
figure_values = {'redonda': 1, 'blanca': 2, 'negra': 4, 'corchea': 8,
'semicorchea': 16, 'fusa': 32, 'semifusa': 64}

def p_expression_initial(subexpressions):
  'expression : te co vars voices'
  subexpressions[0] = Node('S', subexpressions[1:])

def p_expression_tempo(subexpressions):
  'te : TEMPO FIGURE NUMBER'
  subexpressions[0] = Node('te', subexpressions[1:])

def p_expression_compass_v(subexpressions):
  'co : COMPASS_V NUMBER DIV NUMBER'
  util_vars['compass'] = subexpressions[2] / subexpressions[4]
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

def p_expression_voice_content(se):
  'voice_content : compass_or_repeat voice_content'
  if se[1].attributes['sum'] != util_vars['compass']:
    raise SemanticException("compass not valid. Sum: " + str(se[1].attributes['sum']) + " expected: " + str(util_vars['compass']))
  se[0] = Node('voice_content', se[1:])

def p_expression_voice_content_empty(s):
  'voice_content :'

def p_expression_compass(s):
  'compass_or_repeat : COMPASS LCURLYBRACKET compass_content RCURLYBRACKET'
  s[0] = Node('compass', s[1:], {'sum': s[3].attributes['sum']} )

def p_expression_compass_repeat(s):
  'compass_or_repeat : REPEAT LPAREN cons_val RPAREN LCURLYBRACKET voice_content RCURLYBRACKET'
  s[0] = Node('repeat', s[1:])

def p_expression_compass_empty(s):
  'compass_or_repeat :'

def p_expression_voice_compass_content_note(s):
  'compass_content : note compass_content '
  s[0] = Node('compass_content', s[1:], {'sum': s[1].attributes['sum'] + s[2].attributes['sum'] })

def p_expression_compass_content_empty(s):
  'compass_content :'
  s[0] = Node('compass_content', [], {'sum': 0 })

def p_expression_voice_compass_content_silence(s):
  'compass_content : silence compass_content'
  s[0] = Node('compass_content', s[1:], {'sum': s[1].attributes['sum'] + s[2].attributes['sum'] })

def p_expression_note(s):
  'note : NOTE LPAREN NOTE_ID COMMA cons_val COMMA figure_duration RPAREN SEMICOLON'
  s[0] = Node('note', s[1:], {'sum': s[7].attributes['fig_val']})

def p_expression_silence(s):
  'silence : SILENCE LPAREN figure_duration RPAREN SEMICOLON'
  s[0] = Node('silence', s[1:], {'sum': s[3].attributes['fig_val']})

def p_expression_figure(s):
  'figure_duration : FIGURE'
  s[0] = Element(s[1], {'fig_val': 1 / figure_values[s[1]]})

def p_expression_duration(s):
  'figure_duration : DURATION'
  s[0] = Element(s[1], {'fig_val': (1 / figure_values[s[1][0:-1]]) * 1.5})

def p_error(subexpressions):
  import pdb; pdb.set_trace()
  raise Exception("Syntax error.")
