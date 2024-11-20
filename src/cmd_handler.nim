import dimscord, os, osproc, asyncdispatch, strutils, options, streams, times


var
  last_channel_id:string
  watch_command_active:bool = false

type
  TCMDHandler* = object
    discord:DiscordClient
    
proc createTCMDHandler*(discord:DiscordClient):TCMDHandler =
  result.discord = discord

proc sendMsg(self:TCMDHandler, m:string, channel_id:string):Future[bool] {.async.} =
  discard await self.discord.api.sendMessage(channel_id, m)
  return true

proc watchCommand(self:TCMDHandler, command:string, channel_id:string):Future[bool] {.async.} =
  echo "running command: " & command
  var
    process_handle = startProcess("./" & command)
    output_handle = outputStream(process_handle)
    msg = await self.discord.api.sendMessage(channel_id, "temp")
    log_stack = newSeq[string]()
    last_print_time = epochTime()
  
  echo "msg id: " & msg.id

  while watch_command_active:
    let log_line = readLine(output_handle)
    echo "log_line: " & log_line
    
    if log_line.len > 0:
      log_stack.add(log_line)
      echo "new log_stack length: " & $(log_stack.len)
      if log_stack.len > 10:
        log_stack.delete(0)
        echo "deleted last enrty"

    if (epochTime() - last_print_time) >= 5:
      echo "printing log to msg"
      last_print_time = epochTime()
      var reverse_log_stack = ""
      var tmp_seq = newSeq[string](log_stack.len)
      for i, x in log_stack:
        tmp_seq[high(tmp_seq) - i] = x
       
      for i in 0..high(log_stack):
        reverse_log_stack &= log_stack[i] & "\n"
      echo "reverse_log_stack: \n" & reverse_log_stack
      
      echo tmp_seq
      
      echo "log_stack:\n" & reverse_log_stack
      
      var edit_msg = await self.discord.api.editMessage(channel_id, msg.id, embeds = @[Embed(
        title: some "watching: '" & command & "'",
        description: some reverse_log_stack,
        color: some 0x7789ec
        )]
      )

      echo "SPAM!"
      echo edit_msg.id
      echo edit_msg.content
      
      
      echo "printed successfully :)" 
  
  close(process_handle)
  discard self.sendMsg("watch beendet", channel_id)
  return true


proc handleMessage*(self:TCMDHandler, m:Message):Future[bool] {.async.} =
  # keep channel id for future use
  last_channel_id = m.channel_id
  
  let mtokens = m.content.split(" ")

  case mtokens[0]:
    of "!ping":
      discard self.sendMsg("Da haben Sie mich falsch angepingt, Sie hätten das anders machen müssen!", m.channel_id)
    of "!pwd":
      var curdir = getCurrentDir()
      discard self.sendMsg("Derzeitig befinde ich mich in: " & curdir, m.channel_id)
    of "!path":
      var combine_tokens  = mtokens[1..^1].join(" ")
      setCurrentDir(combine_tokens)
      discard self.sendMsg("Ich bin jetzt in: " & getCurrentDir(), m.channel_id)
    of "!watch":
      var combine_tokens  = mtokens[1..^1].join(" ")
      discard self.sendMsg("Nein. Also ich sage Ihnen nur, was sie schon wieder angerichtet haben: '" & combine_tokens & "'", m.channel_id)
      watch_command_active = true      
      discard watchCommand(self, combine_tokens, m.channel_id)
    of "!stop":
      if watch_command_active:
        discard self.sendMsg("In Ordnung. Es reicht.", m.channel_id)
        watch_command_active = false
      else:
        discard self.sendMsg("Was meinen Sie damit? Ich mache doch gar nichts! Anzeige ist raus.", m.channel_id)
    else:
      echo "cmd: invalid command, ignoring."
  return true


