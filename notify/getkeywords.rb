
# gets keywords from file, etc
module Getkeywords
  def self.readfile(file)
    keywords = File.read(file).split
    keywords
  end
end
