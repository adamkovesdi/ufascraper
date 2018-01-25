# Uhrforum angebote web scraper script
# written by Adam Kovesdi (c) 2017
require 'open-uri'
require 'nokogiri'
require './datparser'

UFAURL = 'https://uhrforum.de/angebote/index'.freeze

# Uhrforum angebote scraper module
module Scraper
  def self.scrapepage(pagenumber)
    url = pagenumber
    url = UFAURL + pagenumber.to_s if pagenumber.is_a?(Integer)
    doc = Nokogiri::HTML(open(url))
    threads = doc.css('.threads').css('.threadbit')
    records = []
    threads.each do |thread|
      records.push(scrapethread(thread))
    end
    records
  end

  def self.removepunctuation(text)
    return if text.nil?
    text.gsub(/[^\nA-Za-z0-9 ]/, '')
  end

  def self.tokenize(text)
    text = removepunctuation(text).downcase
    text.split
  end

  def self.getimageurl(threadlink)
    # Take it easy
    sleep(rand)
    postdoc = Nokogiri::HTML(open(threadlink))
    body = postdoc.css('.postbody')[0]
    body.css('a').each do |l|
      if l['href'] =~ /attachment/
        img = l['href']
        return img
      end
    end
  end

  def self.parsemeta(text)
    text.gsub!(/[[:space:]]/, ' ')
    author, timestamp = text.split(' - ')
    timestamp.gsub!(/Uhr/, '')
    timestamp = Datparser.parsedate(timestamp)
    [author, timestamp]
  end

  def self.scrapethread(thread) # rubocop:disable Metrics/AbcSize
    # title = thread.css('.threadinfo')[0]['title']
    text = thread.css('a.title').text
    sellstatus = thread.css('span.prefix>span').text[1]
    link = thread.css('a.title')[0]['href']
    id = thread['id'].split('_')[1]
    author, timestamp = parsemeta(thread.css('.label').text)
    # Image fetching not implemented here
    # uuse the following helper method to get image:
    # url = getimageurl(threadlink)
    { id: id, sellstatus: sellstatus, text: text, link: link,
      img: nil, timestamp: timestamp.to_i, author: author,
      parsetime: Time.now.to_i }
  end
end
