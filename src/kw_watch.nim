import dimscord, times, options, strutils, asyncdispatch, os

import global_classes, cmd_handler

var homeDir = ""

if getEnv("HOME").len > 0:
  homeDir = getEnv("HOME")
elif getEnv("USERPROFILE").len > 0:
  homeDir = getEnv("USERPROFILE")
else:
  echo "HOME DIR NOT FOUND???"

let discord = newDiscordClient(readFile(homeDir & "/discord_token.txt").strip)

var
  cmd:TCMDHandler

# Handle event for on_ready.
proc onReady(s: Shard, r: Ready) {.event(discord).} =
    echo "Ready as " & $r.user
    cmd = createTCMDHandler(discord)

# Handle event for message_create.
proc messageCreate(s: Shard, m: Message) {.event(discord).} =
    if m.author.bot: return
    discard await cmd.handleMessage(m)
    
# Connect to Discord and run the bot.
waitFor discord.startSession()
