# Description:
#   yo
#
# Commands:
#   :yo - response "yo"

module.exports = (robot) ->
  robot.respond /yo/i, (msg) ->
    msg.send "yo"