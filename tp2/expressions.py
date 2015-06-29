class Initial(object):

  def __init__(self, items):
    self.items = items

  def name(self):
    return "s"

  def children(self):
    return self.items

class Node(object):

  def __init__(self, label, items):
    self.label = label
    self.items = items

  def name(self):
    return str(self.label)

  def _element(self, x):
    if(x.__class__ == Element or x.__class__ == Node or x.__class__ == Number):
      return x
    else:
      return Element(x)

  def children(self):
    return map(self._element, self.items)

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
