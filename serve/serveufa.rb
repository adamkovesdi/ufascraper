require 'redis'
require 'date'
require 'sinatra'

def td(text)
  "<td> #{text} </td>\n"
end

def redisget
  r = Redis.new(host: 'redis')
  last_keys = r.scan(0, count: '2000')[1]
  array = last_keys.map { |o| r.hgetall(o) }
  array.sort_by { |h| h['timestamp'] }.reverse
end

def htmltable(entry)
  rv = ''
  rv += "<tr>\n"
  rv += td(entry['author'])
  # rubocop:disable Style/FormatStringToken
  rv += td(Time.strptime(entry['timestamp'], '%s'))
  # rubocop:enable Style/FormatStringToken
  rv += td("<a href=\"#{entry['link']}\">#{entry['text']}</a><br />")
  rv += "</tr>\n"
  rv
end

def array_to_table(array)
  lastdate = Time.now.to_date
  rv = "<table>\n"
  array.each do |entry|
    # rubocop:disable Style/FormatStringToken
    newdate = Date.strptime(entry['timestamp'], '%s')
    # rubocop:enable Style/FormatStringToken
    rv += "<tr><td><hr></td></tr>\n" unless lastdate == newdate
    rv += htmltable(entry)
    lastdate = newdate
  end
  rv += '</table>'
end

get '/' do
  last2k = redisget
  if params.key?('filter')
    last2k.select! { |h| h['text'].downcase.include?(params['filter']) }
  end
  array_to_table(last2k)
end
