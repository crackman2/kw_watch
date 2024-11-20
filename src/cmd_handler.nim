  import dimscord, os, osproc, asyncdispatch, strutils


var
  last_channel_id:string


type
  TCMDHandler* = object
    discord:DiscordClient
    
proc createTCMDHandler*(discord:DiscordClient):TCMDHandler =
  result.discord = discord

proc sendMsg(self:TCMDHandler, m:string, channel_id:string):Future[bool] {.async.} =
  discard await self.discord.api.sendMessage(channel_id, m)
  return true

proc handleMessage*(self:TCMDHandler, m:Message):Future[bool] {.async.} =
  # keep channel id for future use
  last_channel_id = m.channel_id
  
  let mtokens = m.content.split(" ")

  case mtokens[0]:
    of "!ping":
      discard self.sendMsg("Da haben sie mich falsch angepingt, sie müssen das anders machen!", m.channel_id)
    else:
      echo "cmd: invalid command, ignoring."
  return true
