from expressions import Silence

# Class to export our AST to Midicomp format.
class MidicompExporter(object):
  def __init__(self, ast):
    self.ast = ast.get_tree()
    self.clicks_por_pulso = 384

  def export(self, output_file):
    try:
      self.stream = open(output_file, 'w')
    except IOError:
      print 'cannot open', output_file
    else:
      try:
        self._export_header()

        self.channel = 0
        self.constants = self.ast.constants()

        # Recorrer las voces y crear una por una
        for voice in self.ast.voices():
          self._export_voice(voice)

      except Exception as exception:
        print 'something went wrong', exception
      finally:
        self.stream.close()


  def _export_header(self):
    ast = self.ast
    self.stream.write("MFile 1 %d 384\n" % (ast.attributes['util_vars']['voices'] +1))

    self.stream.write("MTrk\n")
    self.stream.write("000:00:000 Tempo %d\n" % (ast.tempo().microseconds()))
    self.stream.write("000:00:000 TimeSig %d/%d 24 8\n" % (ast.compass().n, ast.compass().d))
    self.stream.write("000:00:000 Meta TrkEnd\n")
    self.stream.write("TrkEnd\n")


  def _export_voice(self, voice):
    self.compass_counter = 0
    self.channel = self.channel + 1
    self.pulse = 0
    self.click = 0

    self.stream.write("MTrk\n")
    self.stream.write("000:00:000 Meta TrkName \"Voz %d\"\n" % self.channel)
    self.stream.write("000:00:000 ProgCh ch=%d prog=%d\n" % (self.channel, voice.instrument(self.constants)))

    for compass in voice.compasses():
      self._export_compass(compass)

    self.stream.write("%03d:%02d:%03d Meta TrkEnd\n" % (self.compass_counter, self.pulse, self.click))
    self.stream.write("TrkEnd\n")


  def _export_compass(self, compass):
    self.pulse = 0
    self.click = 0

    for note in compass.notes():
      if isinstance(note, Silence):
        self._export_silence(note)
      else:
        self._export_note(note)


  def _export_note(self, note):
    str_aux = "%03d:%02d:%03d %s ch=%d note=%s  vol=%d\n"

    values = (self.compass_counter, self.pulse, self.click, 'On ', self.channel, note.to_s(), 70)
    self.stream.write(str_aux % values)

    self._increase_clicks(note)

    values = (self.compass_counter, self.pulse, self.click, 'Off', self.channel, note.to_s(), 0)
    self.stream.write(str_aux % values)


  def _export_silence(self, silence):
    self._increase_clicks(silence)


  def _increase_clicks(self, note_or_silence):
    note_clicks = self.ast.compass().figure_clicks(note_or_silence.duration.value)

    self.click += note_clicks

    if (self.click >= 384):
      self.pulse += self.click / 384
      self.click = self.click % 384

    if (self.pulse >= self.ast.compass().n):
      self.pulse = 0
      self.compass_counter += 1

