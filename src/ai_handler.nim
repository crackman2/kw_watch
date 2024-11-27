import dimscord, os, strutils, osproc, asyncdispatch, options

import global_classes, watchcmd, spruch, cleanup

var
  prompt_list:seq[string]
  post_index_start = -1
  post_index_end = -1
  post_chunk_size = 4
  ai_gen_lock = false

type
  TAiHandler = object

proc tryParseInt(s: string): bool =
  try:
    discard s.parseInt()  # Try to parse the string as an integer
    return true   # Return true if successful
  except ValueError:
    return false  # Return false if parsing fails

proc recombineTokens(mtokens:seq[string]): string =
  var
    combine_tokens = ""
    errors = false
  if mtokens.len > 1:
    combine_tokens = mtokens[1..^1].join(" ")
    if combine_tokens.strip != "":
      return combine_tokens.strip
    else:
      errors = true
  if errors:
    return ""
  else:
    return combine_tokens.strip


proc printPromptList(self:TCMDHandler, channel_id:string):Future[Message] {.async.} =
  var join_list = ""
  for i in 0..high(prompt_list):
    var num = if i < 10: "0" & $(i) else: $(i)
    join_list &= "[" & num & "]: " & prompt_list[i] & "\n"
  return await self.discord.api.sendMessage(channel_id, embeds = @[Embed(
          title: some "Prompts",
          description: some "```" & join_list & "```",
          color: some 0x7789ec
          )]
        )
  

proc aiCommand*(self:TCMDHandler, command:string, mtokens:seq[string], channel_id:string):Future[bool] {.async.} =
  
  case mtokens[1]:
  of "help":
    discard await self.sendMsg("""Sie sehen auch aus als würden Sie hilfe benötigen:
```
list
-> Prompt-Liste anzeigen

add <Prompt Text>
-> Fügt Prompt mit Text hinzu

del <index> oder del <index start>..<index ende>
-> Löscht Elemente in der Prompt-Liste

del alles
-> Löscht gesamte Prompt-Liste

post <optionaler index>
-> ohne index werden einfach die neuesten generierten prompts gepostet. looped auch wieder zum anfang
-> index um einzelnen sound zu posten
```
    """, channel_id)
  of "add":
    var length_check = command.splitWhitespace
    if length_check.len != 2:
      var
        command_lines = command.splitLines
        #remove the words (!ai add)
        first_line = command_lines[0].splitWhitespace
      command_lines[0] = first_line[2..^1].join(" ")
      prompt_list.add(command_lines)
      discard await printPromptList(self, channel_id)
      echo "ai : adding prompts"
    else:
      discard await self.sendMsg(spruchPicker("aiadderror") & ": '!ai <command> <parameter>'", channel_id)
  of "del":
    if mtokens[2].contains(".."):
      var range_split = mtokens[2].split("..")
      if tryParseInt(range_split[0]):
        if tryParseInt(range_split[1]):
          if (parseInt(range_split[0])) < (parseInt(range_split[1])):
            if (parseInt(range_split[0]) < prompt_list.len) and (parseInt(range_split[0]) >= 0):
              if (parseInt(range_split[1]) < prompt_list.len) and (parseInt(range_split[1]) >= 0):
                #prompt_list = del prompt_list[parseInt(range_split[0])..parseInt(range_split[1])]
                echo "range_split[0]: " & range_split[0]
                echo "range_split[1]: " & range_split[1]
                echo "prompt_list: " & $(prompt_list)
                for i in countdown(parseInt(range_split[1]),parseInt(range_split[0])):
                  echo "  deleting index: " & $(i)
                  echo "    value: " & prompt_list[i]
                  prompt_list.delete(i)
                discard await printPromptList(self, channel_id)
              else:
                echo "ai del: second range out of range"
            else:
              echo "ai del: first range out of range"
          else:
            echo "ai del: first range is not smaller than second"
        else:
          echo "ai del: second number doesnt parse as int"
      else:
        echo "ai del: first number doesnt parse as int"
    else:
      if tryParseInt(mtokens[2]):
        if (parseInt(mtokens[2]) < prompt_list.len) and (parseInt(mtokens[2]) >= 0):
          prompt_list.delete(parseInt(mtokens[2]))
          discard await printPromptList(self, channel_id)
          echo "ai del: deleting index [" & mtokens[2] & "]"
        else:
          discard await self.sendMsg("Den Eintrag git es in der List gar nicht. Schon wieder alles falsch gemacht! '!ai del <index>'", channel_id)
          echo "ai del: invalid index"
      elif mtokens[2] == "alles":
        prompt_list = @[]
        discard await printPromptList(self, channel_id)
        echo "ai del: deleting prompt list"
      else:
        discard await self.sendMsg("Sie müssen da eine Zahl eingeben. Was glauben Sie eigentlich was mit Index gemeint ist? '!ai del <index>' oder '!ai del <index start>..<index ende>'", channel_id)
        echo "ai: invalid command"
  of "list":
    discard await printPromptList(self, channel_id)
    echo "ai list: lisitng prompts"
  of "gen":
    var length_check = command.splitWhitespace
    if length_check.len == 2:
      if not ai_gen_lock:
        ai_gen_lock = true
        if prompt_list.len > 0:
          var
            gen_path = readFile("generate_path.txt")
            combine_list = ""
            curdir = getCurrentDir()
          echo "ai gen: writing prompts to file"
          for i in 0..high(prompt_list):
            if i != high(prompt_list):
              combine_list &= prompt_list[i] & "\n"
            else:
              combine_list &= prompt_list[i]
          writeFile(joinPath(gen_path,"prompts.txt"), combine_list)
          echo "ai gen: writing to [" & joinPath(gen_path,"prompts.txt") & "]"
          echo "ai gen: string length: [" & $(combine_list.len) & "]"
          echo "ai gen: prompts written to file"
          setCurrentDir(gen_path)
          echo "ai gen: changed working dir to [" & gen_path & "]"
          echo "ai gen: running cleanup function"
          #var trash = execCmd(gen_path & "cleanup.sh")
          cleanupWavFiles(gen_path)
          echo "ai gen: starting generation"
          discard watchCommand(self, "startgen", channel_id, true, gen_path)
          echo "ai gen: changing dir back to original working dir [" & curdir & "]"
          setCurrentDir(curdir)
          echo "ai gen: command finished"
          post_index_start = -1
          post_index_end = -1
        else:
          echo "ai gen: prompt list empty. cant generate"
          discard await self.sendMsg(spruchPicker("aigenemptypromptlisterror"), channel_id)
      else:
        discard await self.sendMsg("Also diese AI-Generationsfunktion ist noch gesperrt. Erstmal '!ai gen clear' ", channel_id)
    elif length_check.len == 3:
      if mtokens[2] == "clear":
        ai_gen_lock = false
        discard await self.sendMsg("Die AI-Generationsfunktion sollte wieder gehen.", channel_id)
      else:
        echo "ai gen: gen clear command wasnt 'clear'"
        discard await self.sendMsg(spruchPicker("aigenargserror"), channel_id)
    else:
      echo "ai gen: wrong number of args"
      discard await self.sendMsg(spruchPicker("aigenargserror"), channel_id)
  of "post":
    if mtokens.len == 2:
      var
        send_seq:seq[DiscordFile]
        gen_path = readFile("generate_path.txt")
      echo "ai post: checking post_index_start.."
      if post_index_start == -1:
        echo "ai post: setting post_index_start to 0"
        post_index_start = 0

      if post_index_start + post_chunk_size <= high(prompt_list):
        echo "ai post: post_index_end wont overshoot high of prompt_list"
        post_index_end = post_index_start + post_chunk_size
      else:
        echo "ai post: clamped post_index_end to last index of prompt_list"
        post_index_end = high(prompt_list)

        echo "ai post: slicing prompts to send_seq"
      for i in post_index_start..post_index_end:
        try:
          var tmp_file = DiscordFile(name: $(i) & "_" & prompt_list[i].replace(" ","_") & ".wav", body: readFile(joinPath(gen_path, $(i) & "_" & prompt_list[i].replace(" ","_") & ".wav")))
          send_seq.add(tmp_file)
        except:
          echo "ai post: creating tmp_file threw an exception! index: [" & $(i) & "]"
      #send msg here
      echo "ai post: sending files to channel"
      discard await self.discord.api.sendMessage(channel_id, files=send_seq)

      if post_index_end + 1 <= high(prompt_list):
        post_index_start = post_index_end + 1
      else:
        post_index_start = -1
        post_index_end = -1
    else:
      if tryParseInt(mtokens[2]):
        if (parseInt(mtokens[2]) <= high(prompt_list)) and (parseInt(mtokens[2]) >= 0):
          try:
            var gen_path = readFile("generate_path.txt")
            var tmp_file = DiscordFile(name: mtokens[2] & "_" & prompt_list[parseInt(mtokens[2])].replace(" ","_") & ".wav", body: readFile(gen_path & mtokens[2] & "_" & prompt_list[parseInt(mtokens[2])].replace(" ","_") & ".wav"))
            var send_seq:seq[DiscordFile]
            send_seq.add(tmp_file)
            discard await self.discord.api.sendMessage(channel_id, files=send_seq)
            echo "ai post (single index): posting sound with index [" & mtokens[2] & "]"
          except:
            echo "ai post (single index): something went wrong. exception!"
        else:
          echo "ai post (single index): index out of range"
      else:
        echo "ai post (single index): couldnt post sound via single index. index is not a number"
  else:
    discard await self.sendMsg(spruchPicker("aierror") & " : '!ai <command> <parameter>'", channel_id)
    echo "ai: missing command"



  echo "AiCommand was called"
  #discard await self.sendMsg("AI: Ja das ist auf jeden soweit angekommen. Nett.", channel_id)




