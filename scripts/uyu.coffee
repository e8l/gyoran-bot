# Description
#  Uyu starts diet
#
# Commands:
#  hubot 痩せろ - Response message that he's decided to do diet.
#  hubot ダイエットしろ - same above command.
#
# Author:
#  e8l

declaration = '(´･ェ･｀)ぅ…ぅゅはこれから脂肪を取り去る実験を開始する'

module.exports = (robot) ->

  callback = (msg) ->
    msg.send declaration

  robot.respond /痩せろ/, callback

  robot.respond /ダイエットしろ/, callback
