require 'redis'
require './scraper'

SLEEPINTERVAL = 900
MAX_PAGECOUNT = 30

# UFA to redis logic
class Collect
  attr_reader :redis
  attr_accessor :recordqueue

  def initialize
    @redis = Redis.new
  end

  def testrecord(record)
    redis.exists(record[:id])
  end

  def storerecord(record)
    # { id: id, sellstatus: sellstatus, text: text, link: link,
    #   img: nil, timestamp: Time.now.to_i }
    return if testrecord(record)
    record.each_key { |key| redis.hset(record[:id], key, record[key]) }
    record
  end

  # call this to put records into redis
  def storerecords(array)
    return if array.nil?
    return if array.empty?
    count = 0
    array.each do |record|
      storerecord(record)
      count += 1
    end
    count
  end

  def fillrecords
    records = []
    (1..MAX_PAGECOUNT).each do |page|
      # get new records
      newrecords = Scraper.scrapepage(page).reject { |r| testrecord(r) }
      puts "#{Time.now} Page \##{page} Records: #{newrecords.count}"
      break if newrecords.empty?
      # we have something to proccess
      records |= newrecords
      # throttling
      sleep(rand * page)
    end
    records.reverse
  end

  def mainloop
    loop do
      records = fillrecords
      storerecords(records)
      sleep(SLEEPINTERVAL)
    end
  end
end

c = Collect.new
c.mainloop
