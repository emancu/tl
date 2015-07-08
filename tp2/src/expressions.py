from helpers import figure_values

class Node(object):
  def __init__(self, label, items, attrs = {}):
    self.label = label
    self.items = items
    self.attributes = attrs

  def name(self):
    return str(self.label)

  def _element(self, x):
    if(isinstance(x, Element) or isinstance(x, Node)):
      return x
    else:
      return Element(x)

  def children(self):
    return map(self._element, self.items)

class Initial(Node):
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
    f = figure_values(self.items[0])
    n = self.items[1]

    return 1000000*15*f/n


class DefCompass(Node):
  def __init__(self, items, attrs = {}):
    Node.__init__(self, 'co', items, attrs)
    self.n = items[0]
    self.d = items[1]

  def figure_clicks(self, f):
    if(f.endswith('.')):
      mod = 1.5
      f = f[0:-1]
    else:
      mod = 1

    return 384 * self.d * mod / figure_values(f)


class Voice(Node):
  def __init__(self, items, attrs = {}):
    Node.__init__(self, 'voice', items, attrs)

  def instrument(self, constants):
    instr = self.items[0]

    if(isinstance(instr, Constant)):
      instr = constants[instr.name()]

    if(isinstance(instr, Number)):
      instr = instr.value

    return instr

  def compasses(self):
    array = []
    aux = self.items[1]

    while isinstance(aux, Node):
      child = aux.children()[0]
      if isinstance(child, Repeat):
        array = array + child.compasses()
      else:
        array.append(child)

      aux = aux.children()[-1]

    return array


class Compass(Node):
  def __init__(self, items, attrs = {}):
    Node.__init__(self, 'Compass', items, attrs)

  def notes(self):
    array = []
    aux = self.items[0]

    while isinstance(aux, Node):
      array.append(aux.children()[0])
      aux = aux.children()[-1]

    return array


class Repeat(Node):
  def __init__(self, items, attrs = {}):
    Node.__init__(self, 'Repeat', items, attrs)
    self.times = items[0].value

  def compasses(self):
    array = []
    aux = self.items[1]

    while isinstance(aux, Node):
      array.append(aux.children()[0])
      aux = aux.children()[-1]

    return array * self.times


class Note(Node):
  def __init__(self, items, attrs = {}):
    Node.__init__(self, 'Note', items, attrs)

    self.note = Note.translation_en(items[0])
    self.octave = items[1]
    self.duration = items[2]

  def to_s(self):
    return self.note + str(self.octave.value)

  @staticmethod
  def translation_en(to_translate):
    translation = { 'do': 'c', 're': 'd', 'mi': 'e', 'fa': 'f', 'sol': 'g', 'la': 'a', 'si': 'b' }
    aux = to_translate[-1]

    if( aux == '-' or aux == '+'):
      to_translate = to_translate[:-1]
    else:
      aux = ''

    return translation[to_translate] + aux


class Silence(Note):
  def __init__(self, items, attrs):
    Node.__init__(self, 'Silence', items, attrs)
    self.duration = items[0]


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


class Number(Element):
  def name(self):
    return "num: " + str(self.value)
