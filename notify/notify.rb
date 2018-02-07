require 'rest_client'
require 'json'
require 'redis'
require './getkeywords'

URL = 'https://api.pushjet.io/message'.freeze
COUNT = 2000
REDISHOST = 'redis'.freeze
SLEEPINTERVAL = 60
SECRET = File.read('secret.txt').chomp.strip

def log(text)
  puts "#{Time.now} #{text}"
end

def assemblemessage(text, url)
  data = {
    secret: SECRET,
    message: url,
    title: text,
    level: 3,
    link: url
  }
  data
end

def notify(item)
  log("Notification for #{item['id']}")
  RestClient.post(URL, assemblemessage(item['text'], item['link']))
end

def redisgetarray
  r = Redis.new(host: REDISHOST)
  last_keys = r.scan(0, count: COUNT)[1]
  array = last_keys.map { |o| r.hgetall(o) }
  array.sort_by { |h| h['timestamp'] }.reverse
end

def redistestid(keyword, id)
  r = Redis.new(host: REDISHOST, db: 2)
  r.sismember(keyword, id)
end

def redismarknotified(keyword, id)
  r = Redis.new(host: REDISHOST, db: 2)
  r.sadd(keyword, id)
end

def processkeyword(keyword)
  items = redisgetarray.select { |e| e['text'].include?(keyword) }
  items.each do |item|
    if redistestid(keyword, item['id'])
      # already have it
      # log("Already have #{keyword},#{item['id']}")
    else
      log(item)
      notify(item)
      redismarknotified(keyword, item['id'])
    end
  end
end

$stdout.sync = true
log('Starting')
loop do
  sleep SLEEPINTERVAL
  keywords = Getkeywords.readfile('keywords.txt')
  keywords.each do |kw|
    processkeyword(kw)
  end
end
