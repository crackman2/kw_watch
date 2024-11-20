import dimscord, os, osproc, asyncdispatch, strutils, options, streams


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
  #var command_out = execCmdEx("./" & command & " &> tmp.log &")
  var process_handle = startProcess("./" & command)
  var output_handle = outputStream(process_handle)
  var msg = await self.discord.api.sendMessage(channel_id, "temp")
  while watch_command_active:
    #var (output, exitcode) = execCmdEx("tail -n 25 tmp.log")
    var output = ""
    for i in 0..10:
      var line = readLine(output_handle)
      output = output & "\n" & line

    discard self.discord.api.editMessage(channel_id, msg.id, embeds = @[Embed(
        title: some "Watch Command",
        description: some "output:\n" & output,
        color: some 0x7789ec
        )]
    )
  
    await sleepAsync(5000)
  
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


