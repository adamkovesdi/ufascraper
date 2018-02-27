require 'rest_client'
require 'json'
require 'redis'
require './getkeywords'

URL = 'https://api.pushjet.io/message'.freeze
COUNT = 2000
REDISHOST = 'redis'.freeze
SLEEPINTERVAL = 60
ERRORSLEEPINTERVAL = 1200
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

def notify(item, keyword)
  log("New item for notification #{item['id']} #{item['text']}")
  begin
    RestClient.post(URL, assemblemessage(item['text'], item['link']))
    redismarknotified(keyword, item['id'])
    log(item)
  rescue StandardError => e
    log("Failed notification for #{item['id']} error: #{e}")
    sleep(ERRORSLEEPINTERVAL)
  end
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
      notify(item, keyword)
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
