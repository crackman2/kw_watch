import dimscord, os, osproc, asyncdispatch, strutils, options, streams, times

import global_classes, spruch, ai_handler, watchcmd


var
  last_channel_id:string


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


