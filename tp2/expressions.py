class Initial(object):

  def __init__(self, items):
    self.items = items

  def name(self):
    return "s"

  def children(self):
    return self.items


class Node(object):

  def __init__(self, label, children):
    self.label = label
    self.children = children

  def name(self):
    return str(self.label)

  def children(self):
    return map((lambda x: Element(x)), self.children)


class Tempo(object):

  def __init__(self, figure, number):
    self.figure = figure
    self.number = number

  def name(self):
    return "te"

  def children(self):
    return [ Element('tempo'), Element(self.figure), Number(self.number)]

class Compass(object):

  def __init__(self, value1, value2):
    self.value1 = value1
    self.value2 = value2

  def name(self):
    return "compass: " + str(self.value1) + "/" + str(self.value2)

  def children(self):
    return []

class Vars(object):

  def __init__(self, items):
    self.items = items

  def name(self):
    return "emancu"

  def children(self):
    return self.items

class Element(object):
  def __init__(self, value):
    self.value = value

  def name(self):
    return str(self.value)

  def children(self):
    return []

class Number(object):

  def __init__(self, value):
    self.value = value

  def name(self):
    return "num: " + str(self.value)

  def children(self):
    return []
