
import lexer_rules
import parser_rules

from ply.lex import lex
from ply.yacc import yacc

def dump_ast(ast, output_file):
    output_file.write("digraph {\n")

    edges = []
    queue = [ast]
    numbers = {ast: 1}
    current_number = 2
    while len(queue) > 0:
        node = queue.pop(0)
#        import pdb; pdb.set_trace()

        name = node.name()
        number = numbers[node]
        output_file.write('node[width=1.5, height=1.5, shape="circle", label="%s"] n%d;\n' % (name, number))
        for child in node.children():
            numbers[child] = current_number
            edge = 'n%d -> n%d;\n' % (number, current_number)
            edges.append(edge)
            queue.append(child)
            current_number += 1

    output_file.write("".join(edges))

    output_file.write("}")


lexer = lex(module=lexer_rules)
file = open('example.mus', 'r')
#lexer.input(file.read())
#token = lexer.token()
#while token is not None:
  #print token.value
#  token = lexer.token()

parser = yacc(module=parser_rules)
text = file.read()
ast = parser.parse(text, lexer)

output_file = open("alee.dot", "w")
dump_ast(ast, output_file)
