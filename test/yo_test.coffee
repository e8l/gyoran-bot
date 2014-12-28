expect = require('chai').expect

Robot       = require('hubot/src/robot')  
TextMessage = require('hubot/src/message').TextMessage

describe 'yo', ->  
  robot   = null
  user    = null
  adapter = null

  beforeEach (done) ->
    robot = new Robot(null, 'mock-adapter', false, 'hubot')

    robot.adapter.on 'connected', ->
      require('../scripts/yo')(robot)
      user = robot.brain.userForId '1',
        name: 'mocha'
        room: '#mocha'
      adapter = robot.adapter
      done()
    robot.run()

  afterEach -> robot.shutdown()

  it 'responds "yo"', (done) ->
    adapter.on 'send', (envelope, strings) ->
      expect(envelope.user.name).to.equal('mocha')
      expect(strings[0]).to.equal('yo')
      done()

    adapter.receive(new TextMessage(user, 'hubot yo'))