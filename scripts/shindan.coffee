Redis = require 'redis'
Request = require 'request'
Cheerio = require 'cheerio'

##################################################
class RedisStorage
  constructor: (context) ->
    if !context
      throw new Error 'Context is required.'
    if !context.url
      throw new Error 'Redis url is required.'
    if !context.keyspace
      throw new Error 'Redis keyspace is required.'
    @Redis = Redis
    @client = null
    @url = context.url
    @keyspace = context.keyspace
  
  connect: () =>
    if !@client
      @client = @Redis.createClient @url
  
  get: (key, callback) =>
    if !key
      callback(new Error "Key is invalid. key=#{key}", null)
      return 
    
    this.connect()
    @client.get @keyspace + '.' + key, (err, res) ->
      if err
        callback(err, null)
        return
      callback(null, JSON.parse res)
  
  put: (key, value, callback) =>
    if !key
      callback(new Error "Key is invalid. key=#{key}", null)
      return 

    this.connect()
    @client.set @keyspace + '.' + key, value, (err, res) ->
      if err
        callback(err, null)
        return
      callback(null, res)
  
  remove: (key, callback) =>
    if !key
      callback(new Error "Key is invalid. key=#{key}", null)
      return
    
    this.connect()
    @client.del @keyspace + '.' + key, (err, res) ->
      if err
        callback(err, null)
        return
      callback(null, res)
  
  close: =>
    if @client
      @client.quit()
      @client = null

##################################################
class ShindanMaker
  constructor: () ->
    @Request = Request
    @Cheerio = Cheerio
  
  shindan: (shindanId, userName, callback) =>
    if userName == null or userName == undefined
      callback(new Error "Invalid user name. userName=#{userName}", null)
      return
    if !/^[0-9]+$/.test(shindanId)
      callback(new Error "Invalid Shindan ID. shindanId=#{shindanId}", null)
      return
    
    options = 
      uri: 'https://shindanmaker.com/' + shindanId
      timeout: 10 * 1000
      form: { u: userName }
    @Request.post options, (err, res, body) =>
      if err
        e = new Error 'Failed to HTTP request'
        e.cause = err
        callback(e, null)
        return
      if res.statusCode != 200
        callback(new Error 'HTTP status code is ' + res.statusCode, null)
        return
      
      $ = @Cheerio.load body
      result = $('div.result2 > div').text().trim()
      if !result
        if $('title').text().trim() == 'エラー'
          callback(new Error 'Shindan ID "' + shindanId + '" does not exist.', null)
          return
        callback(new Error 'Could not parse response. Assumed output format of "shindanmaker.com" may be outdated.', null)
        return
      
      callback(null, result)

##################################################
storage = new RedisStorage {
  url: process.env.REDISCLOUD_URL
  keyspace: 'shindan'
}
shindanMaker = new ShindanMaker

module.exports = (robot) ->
  # add shindan
  # \d is equivarent to [0-9]
  # \s+ matches more than one space.
  # ex: @gyoran-bot shindan-register unigacha 586328
  robot.respond /shindan-register\s+(\w+)\s+(\d+)/, (msg) ->
    shindanName = msg.match[1]
    shindanId = msg.match[2]
    userName = msg.message.user.name
    storage.put shindanName, shindanId, (err, res) ->
      if err
        robot.logger.warn 'SHINDAN: ' + err
        msg.send "#{userName} は診断名を登録できませんでした: #{shindanName} -> #{shindanId}"
      else
        msg.send "#{userName} は診断名を登録しました: #{shindanName} -> #{shindanId}"
      storage.close()

  # Run shindan
  robot.hear /^\s*shindan\s+(\w+)\s*$/, (msg) ->
    shindanName = msg.match[1]
    userName = msg.message.user.name
    storage.get shindanName, (err, res) ->
      if err
        robot.logger.warn 'SHINDAN: ' + err
        msg.send "#{userName} は診断名を逆引きできませんでした"
        return
      if !res
        if ! /^\d+$/.test(shindanName)
          msg.send 'そういう診断はない'
          return
        res = shindanName
      
      shindanMaker.shindan res, userName, (err, res) ->
        if err
          robot.logger.info 'SHINDAN: ' + err
          msg.send "#{userName} は診断に失敗しました"
          return
        msg.send res
        
      storage.close()
  