# Description
#  Fugme is the most important thing in life
#
# Commands:
#  hubot fug me - Take and Receive a fug
#  hubot fug image - Receive a prev fug
#
# Author:
#  ogbeef

api =
  fugme  : process.env.HUBOT_FUG_API_ADDR + '/fugme'
  getfug : process.env.HUBOT_FUG_API_ADDR + '/getfug'

module.exports = (robot) ->

  #Take photo
  robot.respond /fug me/i, (msg) ->
    msg.send 'ϵ( ・Θ・)э < ちょっとまってね'
    robot.http(api.fugme)
    .get() (err, res, body) ->
      if JSON.parse(body).Status == 'OK'
        addr = JSON.parse(body).Address
        msg.send addr
      else
        msg.send 'ϵ( ・Θ・)϶ < 今はあんまり調子が良くない'

  #Get prev photo
  robot.respond /fug image/i, (msg) ->
    robot.http(api.getfug)
    .get() (err, res, body) ->
      addr = JSON.parse(body).Address
      msg.send 'ϵ( ・Θ・)϶ < んご'
      msg.send addr

