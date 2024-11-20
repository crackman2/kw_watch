import dimscord, times, options, strutils, asyncdispatch, os

import cmd_handler

let discord = newDiscordClient(readFile("/home/" & getEnv("USER") & "/discord_token.txt").strip)

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
