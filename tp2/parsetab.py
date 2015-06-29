
# /Users/alemata/facultad/teleng/tps/tp2/parsetab.py
# This file is automatically generated. Do not edit.
_tabversion = '3.5'

_lr_method = 'LALR'

_lr_signature = '43E27B661B1914E18A3AFD9E92961316'
    
_lr_action_items = {'SEMICOLON':([15,16,],[-6,17,]),'CONST':([5,14,],[8,-3,]),'NAME':([8,],[11,]),'FIGURE':([1,],[4,]),'TEMPO':([0,],[1,]),'NUMBER':([4,6,12,13,],[7,10,14,15,]),'EQUAL':([11,],[13,]),'COMPASS_V':([2,7,],[6,-2,]),'DIV':([10,],[12,]),'$end':([3,5,9,14,15,16,17,],[0,-5,-1,-3,-6,-7,-4,]),}

_lr_action = {}
for _k, _v in _lr_action_items.items():
   for _x,_y in zip(_v[0],_v[1]):
      if not _x in _lr_action:  _lr_action[_x] = {}
      _lr_action[_x][_k] = _y
del _lr_action_items

_lr_goto_items = {'co':([2,],[5,]),'te':([0,],[2,]),'expression':([0,],[3,]),'vars':([5,],[9,]),'cons_val':([13,],[16,]),}

_lr_goto = {}
for _k, _v in _lr_goto_items.items():
   for _x, _y in zip(_v[0], _v[1]):
       if not _x in _lr_goto: _lr_goto[_x] = {}
       _lr_goto[_x][_k] = _y
del _lr_goto_items
_lr_productions = [
  ("S' -> expression","S'",1,None,None,None),
  ('expression -> te co vars','expression',3,'p_expression_initial','parser_rules.py',7),
  ('te -> TEMPO FIGURE NUMBER','te',3,'p_expression_tempo','parser_rules.py',11),
  ('co -> COMPASS_V NUMBER DIV NUMBER','co',4,'p_expression_compass','parser_rules.py',15),
  ('vars -> CONST NAME EQUAL cons_val SEMICOLON','vars',5,'p_vars','parser_rules.py',19),
  ('vars -> <empty>','vars',0,'p_vars_empty','parser_rules.py',25),
  ('cons_val -> NUMBER','cons_val',1,'p_cons_val','parser_rules.py',28),
  ('vars -> CONST NAME EQUAL cons_val','vars',4,'p_vars_lambda','parser_rules.py',34),
  ('term -> term TIMES factor','term',3,'p_term_times','parser_rules.py',37),
  ('term -> factor','term',1,'p_term_factor','parser_rules.py',42),
  ('factor -> NUMBER','factor',1,'p_factor_number','parser_rules.py',47),
  ('factor -> LPAREN expression RPAREN','factor',3,'p_factor_expression','parser_rules.py',52),
]