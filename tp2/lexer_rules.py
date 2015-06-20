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

t_TEMPO = "\#tempo"
t_COMPASS_V = "\#compas"
t_FIGURE = "redonda|blanca|negra|corchea|semicorchea|fusa|semifusa"
t_DURATION = "(redonda|blanca|negra|corchea|semicorchea|fusa|semifusa)[\.]"
t_CONST = "const"
t_COMPASS = "compas"
t_NOTE = "nota"
t_NOTE_ID = "(do|re|mi|fa|sol|la|si)[\+|\-]"
t_VOICE = "voz"
t_SILENCE = "silencio"
t_NAME = "\w+"
t_DIV = "/"
t_COMMA = ","
t_LCURLYBRACKET = "{"
t_RCURLYBRACKET = "}"
t_EQUAL = "="
t_PLUS = "\+"
t_TIMES = "\*"
t_LPAREN = "\("
t_RPAREN = "\)"
t_SEMICOLON = ";"

t_ignore_COMMENTS = "//.*"

t_ignore = " \t"

def t_NUMBER(token):
    r"[1-9][0-9]*"
    token.value = int(token.value)
    return token

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
