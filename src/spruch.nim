import random

var
  randomize_init = false
  
  last_index_ping = -1
  last_index_watch = -1
  last_index_watch_error = -1
  last_index_stop_watch = -1
  last_index_stop_watch_error = -1
  last_index_pwd = -1
  last_index_path = -1
  last_index_path_error = -1
  last_index_ai_error = -1
  last_index_ai_add_error = -1
  last_index_ai_gen_args_error = -1
  last_index_ai_gen_empty_prompt_list_error = -1

  sprueche_ping = @[
    "Da haben Sie mich falsch angepingt, Sie hätten das anders machen müssen!",
    "Sie halten sich wohl für besonders lustig, was?",
    "Ich erzähle Ihnen jetzt mal was: Das Pingen war früher viel schneller und einfacher als heutzutage!",
    "Wenn man weiß was man tut, muss man praktisch nie jemanden anpingen. Aber das erfordert eben Können.",
    "Ich weiß nicht ob du mich anpingen _kannst_. _Kannst_ du?",
    "So ein Verhalten hätte es zu meiner Zeit nie gegeben. Was heutzutage alles erlaubt ist... Irrsinn!",
    "So manch einer behauptet ja, dass das Anpingen zum normalen Ablauf dazugehöre. Dies ist ein Trugschluss und das kann ich nicht verstehen und dann muss sowas auch verboten werden!"
  ]

  sprueche_watch = @[
    "Nein. Also ich sage Ihnen nur, was Sie schon wieder angerichtet haben",
    "Folgendes habe ich meinem Anwalt mitgeteilt",
    "Glauben Sie, Sie kommen ungeschoren davon, wenn Sie",
    "In meinem Vorgarten liegen noch Reste von Ihrem",
    "Sie können sich auch nun gar nicht anständig benehmen mit Ihrem",
    "Für sowas gehören Sie in den Bau",
    "Der Fleck auf meinem Pullunder kommt dadruch, dass Sie",
    "Den Schaden müssen Sie mir bezahlen! Es ist nicht normal zu"
  ]

  sprueche_watch_error = @[
    "Also das habe ich jetzt überhaupt nicht verstanden. Ich glaube Sie wissen selbst nicht was Sie wollen.",
    "Für solche Scherzereien habe ich keine Zeit. Nerven Sie jemand anderes!",
    "Sie halten sich wohl für den größten Komiker.",
    "Ich schlage Ihnen gleich mit meinen Birkenstocks das Grinsen aus.",
    "Sie wissen schon, dass Sie sich mit solchen Spielerein strafbar machen, oder?",
    "Netter Versuch, aber ich bin Ihnen mal wieder mit Leichtigkeit überlegen.",
    "Zu meiner Zeit gab es solche Witze gar nicht. Da hat man noch von Natur aus gelacht."
  ]

  sprueche_stop_watch = @[
    "In Ordnung. Es reicht.",
    "Ich hoffe, dass es das letzte Mal gewesen ist.",
    "Ein Dankeschön ist angebracht. Denken Sie mal drüber nach.",
    "Schon vorbei? Ich habe mir bereits gedacht, dass Sie das wieder alles falsch machen.",
    "Schämen Sie sich eigentlich gar nicht? Oder ist das gar Absicht?",
    "Wer so arbeitet, muss sich gar nicht über den Zustand wundern.",
    "Diese ganzen Computer-Fritze machen immer alles nur schlimmer!"
  ]

  sprueche_stop_watch_error = @[
    "Was meinen Sie damit? Ich mache doch gar nichts! Anzeige ist raus.",
    "Was reden Sie denn da für einen Unfug?",
    "Leute wie Sie sollte man wegsperren. Hoffnungslos. Und dann auch noch mit Jogginghose.",
    "Na? Wieder alles kaputt gemacht? Hier ist eine Liste von Menschen, die das überrascht:",
    "Das hat mir fast die Krawatte zerknittert. Passen Sie gefälligst auf, wenn Sie mit solchen Befehlen herumwedeln!",
    "Das mag vielleicht normal sein, wo Sie herkommen. Aber das hier ist DEUTSCHLAND."
  ]

  sprueche_pwd = @[
    "Ich befinde mich derzeitig in: ",
    "Meine Bestellungen bei Tamonda werden geliefert nach: ",
    "Bei mir haben sie neulich das Fenster mit Eiern beworfen in: ",
    "Die Bratwurst schmeckt am besten bei: ",
    "Mit meinen Birkenstocks kann ich sogar hierhin spazieren: ",
    "Hier? Meine Adresse bekommen Sie nicht. Nichtmal diese hier: ",
    "Ich hoffe doch sehr, dass Sie mich mal besuchen kommen. Eintritt 5€: ",
    "Meine Steuererklärung mach im Schlaf bei: ",
    "Die Medikamente erinnern mich daran wo ich wohne: "
  ]

  sprueche_path = @[
    "Umziehen muss jeder mal: ",
    "In den Urlaub fahren war ja so einfach. Ich bin in: ",
    "Schon wieder ein Ausflug. Spannend hier in: ",
    "Ach hätt ich doch nur meinen Fotoappart hierhin mitgenommen: ",
    "So weit weg von zuhause. Ungewohnt in: ",
    "Ich hoffe doch sehr, dass die Leute hier wissen was Bratwurst und Bier ist in: ",
    "Meine Birkenstocks haben mich hierher geführt: ",
    "Ohne meinen Pullunder hätte ich mich nicht hierher getraut: ",
    "Der Mercedes fährt mich mit Stil nach: "
  ]

  sprueche_path_error = @[
    "Ich habe sogar in der App auf meinem Mobiltelefonapparat geschaut, den Ort gibt es so nicht!",
    "Von diesem Land habe ich noch nichts gehört. Muss wohl eines dieser \"-istan\"-Länder sein.",
    "Zu meiner Zeit konnte jeder perfekt Karte lesen. Das können Sie ja scheinbar nicht.",
    "Nein. Also den Ort gibt es gar nicht. Hören Sie auf so einen Unsinn zu verbreiten!",
    "Früher hätte man den Ort viel leichter gefunden. Aber die Zeiten sind vorbei. Schlechte Wegbeschreibung.",
    "Gehen Sie doch selbst dort hin, wenn es diesen Ort gibt! Verarschen kann ich mich auch selber.",
    "Da kommen Sie wohl her, oder? Wie die ganzen anderen nutzlosen Jogginghosenträger."
  ]

  sprueche_ai_error = @[
    "Hier ist was schief gegangen. Diese ganze künstliche Intelligenz Zeug macht die gesamte Bevölkerung immer dümmer und dümmer.",
    "Bald brauchen die deutschen Mitbürgerinnen und Mitbürger schon KI-Hilfe beim Schuhe binden. Alles kaputt!",
    "Ah ja. Mal wieder alls ruiniert. Toll gemacht. Damit hat nun wirklich jeder gerechnet. Soviel zum Thema 'Intelligenz'.",
    "Mein Enkel hat mir mein Smartfon ruiniert mit diesem künstlichen Intelligenz Dreck. Es funktioniert rein gar nichts mehr. Traurig.",
    "Früher hätte es sowas nicht gegeben. Damals waren alle noch von Natur aus intelligent. Nicht so wie die heutige Generation.",
    "Ich glaube du hast damit gerade meinen Mercedes verkratzt. Das ist schon wirklich unangenehm."
  ]

  sprueche_ai_add_error = @[
    "Ich mache nur ordentliche Arbeit, wenn Sie mich auch ordentliche Eigeben übermitteln. Solch einen Unfug können Sie gerne selbst erledigen.",
    "Solche Fehler würden mir ja gar nicht passieren. Lächerlich",
    "Wussten Sie eigentlich, dass Sie auch aussehen wie jemand, der solche Fehler macht?",
    "Also ich persönlich hätte es ja nach dem dritten Mal geschnallt. Sie scheinen wohl eine von Natur aus bestehende Resistenz zu haben.",
    "Können Sie sich eigentlich schon die Schuhe binden?",
    "Das kommt davon wenn man nur Burger und Fritten isst."
  ]

  sprueche_ai_gen_args_error = @[
    "Sie hatten in der Schule wohl auch nur Singen und Klatschen, oder? Zählen jedenfalls nicht.",
    "Das sind einfach zu viele Parameter. Der Befehl ist einfach nur '!ai gen' und nicht mehr. Wie sind Sie eigentlich noch nicht and Ihrer eigenen Sabber ertrunken?",
    "Wer mehr Zahnstein als Hirnzellen hat, muss halt mit solchen Handlungen rechnen. Bitte beim nächsten mal einfach nur '!ai gen'. Danke.",
    "Hübsches Gesicht, gibt's das auch in symmetrisch? Ich hoffe, dass Sie durch die Inzucht auch impotent sind. So eine Dummheit muss im Keim erstickt werden. Beim nächsten Mal dann '!ai gen'.",
    "Es kann in der Welt gar nicht genug Lack zum saufen geben, um jemanden wie Sie zu rechtfertigen. Ich will Ihnen auch gar nicht mehr erklären, was Sie falsch gemacht haben.",
    "Armes Deutschland. Mir fehlen die Worte. Schreiben Sie bitte einfach '!ai gen', wie ein normaler Mensch es tun würde. Dankeschön."
  ]

  sprueche_ai_gen_empty_prompt_list_error = @[
    "Sie müssen schon ein paar Sachen in die Prompt-Liste eintragen, sonst wird das hier nie etwas.",
    "Hat Sie dir Kreativität verlassen? Die Prompt-Liste ist leer und nur Sie selbst sind dran Schuld. Sie hätten ja auch einfach mal aufpassen können.",
    "Prompt-Liste... mehr kann man dazu nicht sagen. Armes Deutschland.",
    "Da hat Ihr Jogginghosenträgerhirn Ihnen mal wieder einen Stock in die Speichen geworfen. Prompt-Liste vergessen und gelbe Zähne. Hier eine Liste von Menschen, die das überrascht:",
    "Sind sie als Kind zwanzig mal vom Wickeltisch gefallen? PROMPT-LISTE. Sie waren halt einfach mal wieder zu faul nachzugucken...",
    "Also... Nein... Früher wäre das nicht passiert. Da haben alle noch auf ihre Prompt-Listen Acht gegeben. Nicht so wie heute mit dieser Jogginghosengeneration."
  ]

proc spruchRnd():void =
  if not randomize_init:
    randomize()
    randomize_init = true

proc spruchPicker*(topic:string):string =
  var
    selected:seq[string]
    last_index:ptr[int]
    index:int
  case topic:
  of "ping":
    selected = sprueche_ping
    last_index = addr last_index_ping
  of "watch":
    selected = sprueche_watch
    last_index = addr last_index_watch
  of "watcherror":
    selected = sprueche_watch_error
    last_index = addr last_index_watch_error
  of "stop":
    selected = sprueche_stop_watch
    last_index = addr last_index_stop_watch
  of "stoperror":
    selected = sprueche_stop_watch_error
    last_index = addr last_index_stop_watch_error
  of "pwd":
    selected = sprueche_pwd
    last_index = addr last_index_pwd
  of "path":
    selected = sprueche_path
    last_index = addr last_index_path
  of "patherror":
    selected = sprueche_path_error
    last_index = addr last_index_path_error
  of "aierror":
    selected = sprueche_ai_error
    last_index = addr last_index_ai_error
  of "aiadderror":
    selected = sprueche_ai_add_error
    last_index = addr last_index_ai_add_error
  of "aigenargserror":
    selected = sprueche_ai_gen_args_error
    last_index = addr last_index_ai_gen_args_error
  of "aigenemptypromptlisterror":
    selected = sprueche_ai_gen_empty_prompt_list_error
    last_index = addr last_index_ai_gen_empty_prompt_list_error
  else:
    return "FEHLER: Da weiß ich bald gar nicht was ich dazu sagen soll. Furchtbar sowas."
  spruchRnd()
  index = last_index[]
  while index == last_index[]:
    index = rand(high(selected))
  last_index[] = index
  return selected[index]
   




