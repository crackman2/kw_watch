import dimscord, os, strutils, osproc, asyncdispatch, options

import global_classes, watchcmd

var
  prompt_list:seq[string]

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
add <Prompt Text>
-> Fügt Prompt mit Text hinzu

del <index> oder del <index start>..<index ende>
-> Löscht Elemente in der Prompt-Liste

del alles
-> Löscht gesamte Prompt-Liste
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
    else:
      discard await self.sendMsg("War schon klar, dass Sie es wieder schaffen das falsch zu machen. '!ai <command> <parameter>'", channel_id)
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
                echo "E: second range out of range"
            else:
              echo "E: first range out of range"
          else:
            echo "E: first range is not smaller than second"
        else:
          echo "E: second number doesnt parse as int"
      else:
        echo "E: first number doesnt parse as int"
    else:
      if tryParseInt(mtokens[2]):
        if (parseInt(mtokens[2]) < prompt_list.len) and (parseInt(mtokens[2]) >= 0):
          prompt_list.delete(parseInt(mtokens[2]))
          discard await printPromptList(self, channel_id)
        else:
          discard await self.sendMsg("Den Eintrag git es in der List gar nicht. Schon wieder alles falsch gemacht! '!ai del <index>'", channel_id)
      elif mtokens[2] == "alles":
        prompt_list = @[]
        discard await printPromptList(self, channel_id)
      else:
        discard await self.sendMsg("Sie müssen da eine Zahl eingeben. Was glauben Sie eigentlich was mit Index gemeint ist? '!ai del <index>' oder '!ai del <index start>..<index ende>'", channel_id)
  of "list":
    discard await printPromptList(self, channel_id)
  else:
    discard await self.sendMsg("Sie müssen schon einen Befehl eingeben. Sonst wird das nichts. '!ai <command> <parameter>'", channel_id)



  echo "AiCommand was called"
  #discard await self.sendMsg("AI: Ja das ist auf jeden soweit angekommen. Nett.", channel_id)




