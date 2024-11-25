import dimscord, os, osproc, asyncdispatch, strutils, options, streams, times

import global_classes, spruch, ai_handler


var
  last_channel_id:string
  watch_command_active:bool = false
  
proc sendMsg(self:TCMDHandler, m:string, channel_id:string):Future[bool] {.async.} =
  discard await self.discord.api.sendMessage(channel_id, m)
  return true

proc readLineAsync(s:Stream):Future[string] {.async.} =
  return readLine(s)

proc watchCommand(self:TCMDHandler, command:string, channel_id:string):Future[bool] {.async.} =
  if not (command in self.command_whitelist):
    #discard self.sendMsg("Wer glauben Sie eigentlich wer Sie sind? Das dürfen Sie nicht und Sie werden von meinem Anwalt hören.", channel_id)
    echo "ERROR: command not in whitelist. stopping !watch"
    discard await self.sendMsg(spruchPicker("watcherror"), channel_id)
    watch_command_active = false
    raise newException(ValueError, "invalid command")
    return false

  echo "running command: " & command
  discard await self.sendMsg(spruchPicker("watch") & " : '" & command & "'", channel_id)

  var
    process_handle = startProcess("./" & command)
    output_handle = outputStream(process_handle)
    msg = await self.discord.api.sendMessage(channel_id, "temp")
    log_stack = newSeq[string]()
    last_print_time = epochTime()
  
  echo "msg id: " & msg.id

  while watch_command_active:
    var log_line = ""

    try:
      log_line = await readLineAsync(output_handle)
      echo "kw_watch '" & command& "': " & log_line
    except:
      echo "ERROR: couldn't read stdout. Exiting Loop"
      watch_command_active = false
      break

    if log_line.len > 0:
      log_stack.add(log_line)
      #echo "new log_stack length: " & $(log_stack.len)
      if log_stack.len > 10:
        log_stack.delete(0)
        #echo "deleted last enrty"

    if (epochTime() - last_print_time) >= 5:
      #echo "printing log to msg"
      last_print_time = epochTime()
      var reverse_log_stack = ""
      var tmp_seq = newSeq[string](log_stack.len)
      for i, x in log_stack:
        tmp_seq[high(tmp_seq) - i] = x
       
      for i in 0..high(log_stack):
        reverse_log_stack &= log_stack[i] & "\n"
      #echo "reverse_log_stack: \n" & reverse_log_stack
      
      #echo tmp_seq
      
      #echo "log_stack:\n" & reverse_log_stack
      
      var edit_msg = await self.discord.api.editMessage(channel_id, msg.id, embeds = @[Embed(
        title: some "watching: '" & command & "'",
        description: some reverse_log_stack,
        color: some 0x7789ec
        )]
      )

      #echo "SPAM!"
      #echo edit_msg.id
      #echo edit_msg.content
      
      
      #echo "printed successfully :)" 
  
  close(process_handle)
  #discard self.sendMsg("watch beendet", channel_id)
  echo "watch ended"
  return true


proc handleMessage*(self:TCMDHandler, m:Message):Future[bool] {.async.} =
  # keep channel id for future use
  last_channel_id = m.channel_id
  
  let mtokens = m.content.split(" ")

  case mtokens[0]:
    of "!help":
      var edit_msg = await self.discord.api.sendMessage(m.channel_id, embeds = @[Embed(
        title: some "Befehle",
        description: some "!ping\n!pwd\n!path\n!watch\n!stop",
        color: some 0x7789ec
        )]
      )
    of "!ping":
      discard self.sendMsg(spruchPicker("ping"),m.channel_id)
    of "!pwd":
      var curdir = getCurrentDir()
      discard self.sendMsg(spruchPicker("pwd") & curdir, m.channel_id)
    of "!path":
      var
        combine_tokens = ""
        errors = false
      if mtokens.len > 1:
        combine_tokens = mtokens[1..^1].join(" ")
        if combine_tokens.strip != "":
          try:
            setCurrentDir(combine_tokens)
            discard self.sendMsg(spruchPicker("path") & getCurrentDir(), m.channel_id)
          except:
            errors = true
        else:
          errors = true
      else:
        errors = true
      if errors: discard self.sendMsg(spruchPicker("patherror"), m.channel_id)
    of "!watch":
      var
        combine_tokens = ""
        errors = false
      if mtokens.len > 1:
        combine_tokens  = mtokens[1..^1].join(" ")
        if combine_tokens.strip != "":
          watch_command_active = true      
          discard watchCommand(self, combine_tokens, m.channel_id)
        else:
          errors = true
      else:
        errors = true
      if errors: discard self.sendMsg(spruchPicker("watcherror"), m.channel_id)
    of "!stop":
      if watch_command_active:
        discard self.sendMsg(spruchPicker("stop"), m.channel_id)
        watch_command_active = false
      else:
        discard self.sendMsg(spruchPicker("stoperror"), m.channel_id)
    of "!ai":
      var
        combine_tokens = ""
        errors = false
      if mtokens.len > 1:
        combine_tokens  = mtokens[1..^1].join(" ")
        if combine_tokens.strip != "":
          discard aiCommand(self, m.content, mtokens, m.channel_id)
        else:
          errors = true
      else:
        errors = true
      if errors: discard self.sendMsg(spruchPicker("aierror"), m.channel_id)
    else:
      echo "cmd: invalid command, ignoring."
  return true


