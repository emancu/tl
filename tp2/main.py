
from expressions import *
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

def print_output_file(ast, of):
    of.write("MFile 1 %d 384\n" % (ast.attributes['util_vars']['voices'] +1))

    of.write("MTrk\n")
    of.write("000:00:000 Tempo %d\n" % (ast.tempo().microseconds()))
    of.write("000:00:000 TimeSig %d/%d 24 8\n" % (ast.compass().n, ast.compass().d))
    of.write("000:00:000 Meta TrkEnd\n")
    of.write("TrkEnd\n")

    clicks_por_pulso = 384
    channel = 0
    constants = ast.constants()
    # Recorrer las voces y crear una por una
    for voice in ast.voices():
        compass_counter = 0
        channel = channel + 1
        of.write("MTrk\n")
        of.write("000:00:000 Meta TrkName \"Voz %d\"\n" % channel)
        of.write("000:00:000 ProgCh ch=%d prog=%d\n" % (channel, voice.instrument(constants)))

        pulse = 0
        click = 0
        for compass in voice.compasses():
            pulse = 0
            click = 0
            for note in compass.notes():

                note_clicks = ast.compass().figure_clicks(note.duration.value)
                vol = 70
                state = 'On'
                if(not isinstance(note, Silence)):
                    str_aux = "%03d:%02d:%03d %s  ch=%d note=%s  vol=%d\n" % (compass_counter, pulse, click, state, channel, note.to_s(), vol)
                    of.write(str_aux)

                click += note_clicks

                if (click >= 384):
                    pulse += click / 384
                    click = click % 384

                if (pulse >= ast.compass().n):
                    pulse = 0
                    compass_counter += 1

                vol = 0
                state = 'Off'
                if(not isinstance(note, Silence)):
                    str_aux = "%03d:%02d:%03d %s ch=%d note=%s  vol=%d\n" % (compass_counter, pulse, click, state, channel, note.to_s(), vol)
                    of.write(str_aux)

        of.write("%03d:%02d:%03d Meta TrkEnd\n" % (compass_counter, pulse, click))
        of.write("TrkEnd\n")


lexer = lex(module=lexer_rules)
file = open('example.mus', 'r')

parser = yacc(module=parser_rules)
text = file.read()
try:
    ast = parser.parse(text, lexer)
    output_file = open("alee.dot", "w")
    dump_ast(ast, output_file)
    print_output_file(ast, open("output.txt", "w"))
except Exception as exception:
    print "Syntax error " + str(exception)
except parser_rules.SemanticException as exception:
    print "Semantic error: " + str(exception)
else:
    print "Syntax is valid."

