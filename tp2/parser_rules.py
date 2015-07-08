from __future__ import division
from lexer_rules import tokens
from expressions import *

class SemanticException(Exception):
  pass

names = {}
util_vars = { 'voices': 0 }
figure_values = {'redonda': 1, 'blanca': 2, 'negra': 4, 'corchea': 8,
'semicorchea': 16, 'fusa': 32, 'semifusa': 64}

def p_expression_initial(se):
  'expression : te co vars voices'
  se[0] = Initial(se[1:], {'names': names, 'util_vars': util_vars})

def p_expression_tempo(se):
  'te : TEMPO FIGURE NUMBER'
  se[0] = Tempo([se[2], se[3]])

def p_expression_compass_v(se):
  'co : COMPASS_V NUMBER DIV NUMBER'
  util_vars['compass'] = se[2] / se[4]
  se[0] = DefCompass([se[2], se[4]])

def p_vars(se):
  'vars : vars CONST NAME EQUAL cons_val SEMICOLON'
  name = se[3]
  cons_val = se[5]

  if name in names:
    raise SemanticException("const '" + name + "' is already defined")

  if (cons_val.__class__ == Number):
    names[name] = cons_val.value
  elif cons_val.name() in names:
    names[name] = names[cons_val.name()]
  else:
    raise SemanticException("const '" + cons_val.name() + "' is undefined")

  se[0] = Node('vars', [se[1], se[3], se[5]])

def p_vars_empty(se):
  'vars :'

def p_cons_val_number(se):
  'cons_val : NUMBER'
  se[0] = Number(se[1])

def p_cons_val_name(se):
  'cons_val : NAME'
  se[0] = Constant(se[1], names[se[1]])

def p_expression_voices(s):
  'voices : voice voices'
  util_vars['voices'] = util_vars['voices'] + 1
  s[0] = Node('voices', s[1:])

def p_expression_voices_empty(s):
  'voices :'

def p_expression_voice(se):
  'voice : VOICE LPAREN cons_val RPAREN LCURLYBRACKET voice_content RCURLYBRACKET'
  cons_val = se[3]
  if (cons_val.__class__ == Element and not(cons_val.value in names)):
    raise SemanticException("const '" + cons_val.value + "' is undefined")

  se[0] = Voice([se[3], se[6]])

def p_expression_voice_content(se):
  'voice_content : compass_or_repeat voice_content'

  if se[1].attributes['sum'] != util_vars['compass']:
    raise SemanticException("compass not valid. Sum: " + str(se[1].attributes['sum']) + " expected: " + str(util_vars['compass']))
  se[0] = Node('voice_content', se[1:], {'sum': se[1].attributes['sum']})

def p_expression_voice_content_empty(s):
  'voice_content :'

def p_expression_compass(se):
  'compass_or_repeat : COMPASS LCURLYBRACKET compass_content RCURLYBRACKET'
  se[0] = Compass([se[3]], {'sum': se[3].attributes['sum']} )

def p_expression_compass_repeat(se):
  'compass_or_repeat : REPEAT LPAREN cons_val RPAREN LCURLYBRACKET repeat_content RCURLYBRACKET'
  se[0] = Repeat([se[3], se[6]], {'sum': se[6].attributes['sum']})

def p_expression_repeat_content(se):
  'repeat_content : compass repeat_content '
  se[0] = Node('repeat_content', se[1:], {'sum': se[1].attributes['sum']} )

def p_expression_compass_only(se):
  'compass : COMPASS LCURLYBRACKET compass_content RCURLYBRACKET'
  se[0] = Compass([se[3]], {'sum': se[3].attributes['sum']} )

def p_expression_repeat_content_empty(se):
  'repeat_content :'

def p_expression_compass_empty(se):
  'compass_or_repeat :'

def p_expression_voice_compass_content_note(se):
  'compass_content : note compass_content '

  sum_aux = se[1].attributes['sum']
  if(se[2] is not None):
    sum_aux += se[2].attributes['sum']

  se[0] = Node('compass_content', se[1:], {'sum': sum_aux })

def p_expression_compass_content_empty(s):
  'compass_content :'

def p_expression_voice_compass_content_silence(se):
  'compass_content : silence compass_content'

  sum_aux = se[1].attributes['sum']
  if(se[2] is not None):
    sum_aux += se[2].attributes['sum']

  se[0] = Node('compass_content', se[1:], {'sum': sum_aux})

def p_expression_note(se):
  'note : NOTE LPAREN NOTE_ID COMMA cons_val COMMA figure_duration RPAREN SEMICOLON'
  se[0] = Note([se[3], se[5], se[7]], {'sum': se[7].attributes['fig_val']})

def p_expression_silence(se):
  'silence : SILENCE LPAREN figure_duration RPAREN SEMICOLON'
  se[0] = Silence([se[3]], {'sum': se[3].attributes['fig_val']})

def p_expression_figure(se):
  'figure_duration : FIGURE'
  se[0] = Element(se[1], {'fig_val': 1 / figure_values[se[1]]})

def p_expression_duration(se):
  'figure_duration : DURATION'
  se[0] = Element(se[1], {'fig_val': (1 / figure_values[se[1][0:-1]]) * 1.5})

def p_error(subexpressions):
  raise Exception("at line: %s, token: %s" % (subexpressions.lineno, subexpressions.type) )
