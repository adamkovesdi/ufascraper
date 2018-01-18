require 'redis'
require './scraper'

SLEEPINTERVAL = 900
MAX_PAGECOUNT = 15

def storerecord(record, redis)
  # { id: id, sellstatus: sellstatus, text: text, link: link,
  #   img: nil, timestamp: Time.now.to_i }
  return if redis.exists(record[:id])
  record.each_key { |key| redis.hset(record[:id], key, record[key]) }
  record
end

def storerecords(records)
  r = Redis.new
  storedcount = 0
  records.each do |record|
    result = storerecord(record, r)
    storedcount += 1 unless result.nil?
  end
  storedcount
end

def parsepages(n)
  records = []
  n.times do |i|
    # slow down
    sleep(rand)
    records |= Scraper.scrapepage(i + 1)
  end
  records.reverse
end

def testrecord(record, redis)
  redis.exists(record[:id])
end

def dopages(maxnumber)
  index = 1
  loop do
    # parse some pages
    break if index >= maxnumber
  end
end

def mainloopold
  loop do
    newentries = storerecords(parsepages(2))
    puts newentries
    sleep(SLEEPINTERVAL)
  end
end

mainloopold
