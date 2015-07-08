import lexer_rules
import parser_rules

from ply.lex import lex
from ply.yacc import yacc

class AST(object):
  def __init__(self, input_file):
    self._parse(input_file)

  def get_tree(self):
    return self.ast

  # Dump the AST into a .dot file to see the tree as a digraph.
  def dump_ast(self, output_file):
    try:
      edges = []
      queue = [self.ast]
      numbers = {ast: 1}
      current_number = 2

      f = open(output_file, 'w')
      f.write("digraph {\n")

      while len(queue) > 0:
        node = queue.pop(0)
        name = node.name()
        number = numbers[node]
        f.write('node[width=1.5, height=1.5, shape="circle", label="%s"] n%d;\n' % (name, number))

        for child in node.children():
          numbers[child] = current_number
          edge = 'n%d -> n%d;\n' % (number, current_number)
          edges.append(edge)
          queue.append(child)
          current_number += 1

      f.write("".join(edges))
      f.write("}")

      f.close()
    except IOError:
      print "Error: can\'t find file or read data"
    else:
      print "AST dumped successfully"


  # Reads input file and returns the parsed AST.
  def _parse(self, input_file):
    lexer = lex(module=lexer_rules)
    parser = yacc(module=parser_rules)

    try:
      file = open(input_file, 'r')

      self.ast = parser.parse(file.read(), lexer)

      file.close()
    except IOError:
      print "Error: can\'t find file or read data"


