require 'date'

# rubocop:disable Style/FormatStringToken
DATEFORMAT = '%d.%m.%Y'.freeze
# rubocop:enable Style/FormatStringToken

# Parse date object to date
module Datparser
  def self.normalize(string)
    d, t = string.split(',').map(&:strip)
    if d == 'Gestern'
      d = (Date.today - 1)
      d = d.strftime(DATEFORMAT)
    elsif d == 'Heute'
      d = Date.today
      d = d.strftime(DATEFORMAT)
    end
    d + ', ' + t
  end

  def self.parsedate(string)
    dat, tim = normalize(string).split(',').map(&:strip)
    d, m, y = dat.split('.').map(&:to_i)
    hour, min = tim.split(':').map(&:to_i)
    Time.local(y, m, d, hour, min, 0)
  end
end
