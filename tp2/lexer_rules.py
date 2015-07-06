tokens = [
    'TEMPO',
    'COMPASS_V',
    'FIGURE',
    'CONST',
    'COMPASS',
    'NOTE',
    'SILENCE',
    'REPEAT',
    'DURATION',
    'NOTE_ID',
    'VOICE',
    'NAME',
    'DIV',
    'COMMA',
    'RCURLYBRACKET',
    'LCURLYBRACKET',
    'EQUAL',
    'NUMBER',
    'PLUS',
    'TIMES',
    'LPAREN',
    'RPAREN',
    'SEMICOLON'
]

def t_COMMENT(t):
    "//.*"
def t_TEMPO(t):
    "\#tempo"
    return t
def t_COMPASS_V(t):
    "\#compas"
    return t
def t_DURATION(t):
    "(redonda|blanca|negra|corchea|semicorchea|fusa|semifusa)[\.]"
    return t
def t_FIGURE(t):
    "redonda|blanca|negra|corchea|semicorchea|fusa|semifusa"
    return t
def t_CONST(t):
    "const"
    return t
def t_COMPASS(t):
    "compas"
    return t
def t_NOTE(t):
    "nota"
    return t
def t_SILENCE(t):
    "silencio"
    return t
def t_REPEAT(t):
    "repetir"
    return t
def t_NOTE_ID(t):
    "(do|re|mi|fa|sol|la|si)[\+|\-]?"
    return t
def t_VOICE(t):
    "voz"
    return t
def t_DIV(t):
    "/"
    return t
def t_COMMA(t):
    ","
    return t
def t_LCURLYBRACKET(t):
    "{"
    return t
def t_RCURLYBRACKET(t):
    "}"
    return t
def t_EQUAL(t):
    "="
    return t
def t_PLUS(t):
    "\+"
    return t
def t_LPAREN(t):
    "\("
    return t
def t_RPAREN(t):
    "\)"
    return t
def t_SEMICOLON(t):
    ";"
    return t
def t_NUMBER(token):
    r"[1-9][0-9]*"
    token.value = int(token.value)
    return token

def t_NAME(t):
    "\w+"
    return t


t_ignore = " \t"

def t_error(token):
    message = "Token desconocido:"
    message = "\ntype:" + token.type
    message += "\nvalue:" + str(token.value)
    message += "\nline:" + str(token.lineno)
    message += "\nposition:" + str(token.lexpos)
    raise Exception(message)

def t_NEWLINE(token):
  r"\n+"
  token.lexer.lineno += len(token.value)
