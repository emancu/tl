class Initial(object):

  def __init__(self, items):
    self.items = items

  def name(self):
    return "s"

  def children(self):
    return self.items

class Node(object):

  def __init__(self, label, items, attrs = {}):
    self.label = label
    self.items = items
    self.attributes = attrs

  def name(self):
    return str(self.label)

  def _element(self, x):
    if(isinstance(x, Element) or isinstance(x, Node) or x.__class__ == Number):
      return x
    else:
      return Element(x)

  def children(self):
    return map(self._element, self.items)

class Main(Node):
  def __init__(self, items, attrs = {}):
    Node.__init__(self, 'S', items, attrs)

  def tempo(self):
    return self.items[0]

  def compass(self):
    return self.items[1]

  def voices(self):
    v_array = []
    voices_v = self.items[-1]

    while isinstance(voices_v, Node):
      v_array.append(voices_v.children()[0])
      voices_v = voices_v.children()[-1]

    return v_array

  def constants(self):
    return self.attributes['names']


class Tempo(Node):
  def __init__(self, items, attrs = {}):
    Node.__init__(self, 'te', items, attrs)

  def microseconds(self):
    figure_values = {'redonda': 1, 'blanca': 2, 'negra': 4, 'corchea': 8, 'semicorchea': 16, 'fusa': 32, 'semifusa': 64}
    f = figure_values[self.items[1]]
    n = self.items[2]

    return 1000000*15*f/n

class DefCompass(Node):
  def __init__(self, items, attrs = {}):
    Node.__init__(self, 'co', items, attrs)
    self.n = items[1]
    self.d = items[3]

  def figure_clicks(self, f):
    if(f.endswith('.')):
      mod = 1.5
      f = f[0:-1]
    else:
      mod = 1

    figure_values = {'redonda': 1, 'blanca': 2, 'negra': 4, 'corchea': 8, 'semicorchea': 16, 'fusa': 32, 'semifusa': 64}
    # TODO: Que pasa con el puntillo.

    return 384 * self.d * mod / figure_values[f]

class Voice(Node):
  def __init__(self, items, attrs = {}):
    Node.__init__(self, 'voice', items, attrs)

  def instrument(self, constants):
    instr = self.items[2]

    if(isinstance(instr, Constant)):
      instr = constants[instr.name()]

    if(isinstance(instr, Number)):
      instr = instr.value

    return instr

  def compasses(self):
    array = []
    aux = self.items[-2]

    while isinstance(aux, Node):
      array.append(aux.children()[0])
      aux = aux.children()[-1]

    return array


class Compass(Node):
  def __init__(self, items, attrs = {}):
    Node.__init__(self, 'Compass', items, attrs)

  def notes(self):
    array = []
    aux = self.items[-2]

    while isinstance(aux, Node):
      array.append(aux.children()[0])
      aux = aux.children()[-1]

    return array


class Note(Node):
  def __init__(self, items, attrs = {}):
    Node.__init__(self, 'Note', items, attrs)
    self.note = Note.translation_en()[items[2]]
    self.octave = items[4]
    self.duration = items[6]

  def to_s(self):
    return self.note + str(self.octave.value)

  @staticmethod
  def translation_en():
    return { 'do': 'c', 're': 'd', 'mi': 'e', 'fa': 'f', 'sol': 'g', 'la': 'a', 'si': 'b' }


class Silence(Note):
  def __init__(self, items, attrs):
    Node.__init__(self, 'Silence', items, attrs)
    self.duration = items[2]

  def to_s(self):
    return 'AAAAAAAA'

class Element(object):
  def __init__(self, value, attrs = {}):
    self.value = value
    self.attributes = attrs

  def name(self):
    return str(self.value)

  def children(self):
    return []


class Constant(Element):
  def __init__(self, name, int_value):
    self.var_name = name
    self.value = int_value

  def name(self):
    return self.var_name

class Number(object):

  def __init__(self, value, attrs = {}):
    self.value = value
    self.attributes = attrs

  def name(self):
    return "num: " + str(self.value)

  def children(self):
    return []
