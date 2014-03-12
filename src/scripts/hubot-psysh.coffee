# Description:
#   Psysh wrapper
#
# Dependencies:
#   None
#
# Configuration:
#
# Commands:
#   hubot ? php (code)
#
# Author:
#   gaving

'use strict'

child = require('child_process')

module.exports = (robot) ->
  psysh = child.spawn('psysh')

  if robot.adapter.constructor.name is 'IrcBot'
    bold = (text) ->
      "\x02" + text + "\x02"
    underline = (text) ->
      "\x1f" + text + "\x1f"
  else
    bold = (text) ->
      text
    underline = (text) ->
      text

  psysh.stdout.on 'data', (data) ->
    output = data.toString().trim()
    n = output.indexOf('\u23CE')
    output = output.substring(0, n).trim() if n isnt -1
    psysh.send bold(output) if psysh.send? and (output.charAt(0) not in [">", "=", "\u23CE"])

  psysh.stdin.on 'end', ->
    psysh.send underline('psysh ended')
    return

  psysh.on 'exit', (code) ->
    psysh.send underline('psysh died')
    return

  robot.respond /\? (.*)/i, (msg) ->
    psysh.send = (text) ->
      msg.send text.trim() if text
    psysh.stdin.write "#{msg.match[1]}\n"
