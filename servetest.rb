require 'redis'
require 'sinatra'

get '/' do
  r = Redis.new
  last2k = r.scan(0, count: '2000')[1]
  # last2k.select! { |id| r.hget(id, 'text').downcase =~ /filter/ }
  rv = ''
  last2k.each do |id|
    rv += "<a href=\"#{r.hget(id, 'link')}\">#{r.hget(id, 'text')}</a><br />\n"
  end
  rv
end
