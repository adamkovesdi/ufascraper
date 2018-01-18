# Uhrforum angebote web scraper script
# written by Adam Kovesdi (c) 2017
require 'open-uri'
require 'nokogiri'

# Uhrforum angebote scraper module
module Scraper
  # Call this to proccess a page
  def self.scrapepage(pagenumber)
    url = "https://uhrforum.de/angebote/index#{pagenumber}"
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

  def self.scrapethread(thread)
    # title = thread.css('.threadinfo')[0]['title']
    text = thread.css('a.title').text
    sellstatus = thread.css('span.prefix>span').text[1]
    link = thread.css('a.title')[0]['href']
    id = thread['id'].split('_')[1]
    # Image fetching not implemented here
    # uuse the following helper method to get image:
    # url = getimageurl(threadlink)
    { id: id, sellstatus: sellstatus, text: text, link: link,
      img: nil, timestamp: Time.now.to_i }
  end
end
