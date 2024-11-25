import dimscord, strutils, asyncdispatch, streams, os, osproc, times, options

import spruch, global_classes

var
  watch_command_active*:bool = false

 

proc readLineAsync*(s:Stream):Future[string] {.async.} =
  return readLine(s)

proc watchCommand*(self:TCMDHandler, command:string, channel_id:string):Future[bool] {.async.} =
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
        description: some "```" & reverse_log_stack & "```",
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