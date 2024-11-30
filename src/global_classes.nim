import dimscord, strutils, asyncdispatch, os, options

type
  TCMDHandler* = object
    discord*:DiscordClient
    command_whitelist*:seq[string]


proc createTCMDHandler*(discord:DiscordClient):TCMDHandler =
  result.discord = discord
  var cmd_list:string
  try:
    cmd_list = readFile("whitelist.txt")
    result.command_whitelist = cmd_list.splitLines
  except:
    echo "ERROR: couldn't read whitelist"
    result.command_whitelist = @[""]

proc sendMsg*(self:TCMDHandler, m:string, channel_id:string):Future[bool] {.async.} =
  discard await self.discord.api.sendMessage(channel_id, m)
  return true
