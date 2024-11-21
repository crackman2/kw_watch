import random

var
  randomize_init = false
  
  last_index_ping = -1
  last_index_commandexecuted = -1

  sprueche_ping = [
    "Da haben Sie mich falsch angepingt, Sie hätten das anders machen müssen!",
    "Sie halten sich wohl für besonders lustig, was?",
    "Ich erzähle Ihnen jetzt mal was: Das Pingen hat war früher viel schneller und einfacher als heutzutage!",
    "Wenn man weiß was man tut, muss man praktisch nie jemanden anpingen. Aber das erfordert eben Können.",
    "Ich weiß nicht ob du mich anpingen _kannst_. _Kannst_ du?",
    "So ein Verhalten hätte zu meiner Zeit nie gegeben. Was heutzutage alles erlaubt ist... Irrsinn!",
    "So manch einer behauptet ja, dass das Anpingen zum normalen Ablauf dazugehöre. Dies ist ein Trugschluss und das kann ich nicht verstehen und dann muss sowas auch verboten werden!"
  ]

  sprueche_befehl_ausgefuehrt = [
    "Nein. Also ich sage Ihnen nur, was sie schon wieder angerichtet haben",
    "Folgendes habe ich meinem Anwalt mitgeteilt",
    "Glauben Sie, sie kommen ungeschoren davon, wenn Sie",
    "In meinem Vorgarten liegen noch Reste von Ihrem",
    "Sie können sich auch nun gar nicht anständig benehmen mit Ihrem",
    "Für sowas gehören Sie in den Bau",
    "Der Fleck auf meinem Pullunder kommt dadruch, dass Sie",
    "Den Schaden müssen Sie mir bezahlen! Es ist nicht normal zu"
  ]

proc spruchRnd():void =
  if not randomize_init:
    randomize()
    randomize_init = true

proc spruchPing*():string =
  spruchRnd()
  var index = last_index_ping
  while index == last_index_ping:
    index = rand(high(sprueche_ping))
  last_index_ping = index
  return sprueche_ping[index]

proc spruchCommandExecuted*():string =
  spruchRnd()
  var index = last_index_commandexecuted
  while index == last_index_commandexecuted:
    index = rand(high(sprueche_befehl_ausgefuehrt))
  last_index_commandexecuted = index
  return sprueche_befehl_ausgefuehrt[index]

 
