# vim: ai ts=2 sts=2 et sw=2 ft=ruby
# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=ruby
clearing :on

guard :shell do
  watch(/(.*).rb/) do |m|
    puts '------------------------------------------'
    puts ' ' + Time.now.to_s
    puts " Static code analyisis #{m[0]}"
    puts '------------------------------------------'
    `rubocop --color #{m[0]}`
  end
end

guard :shell do
  watch(/README.md/) do |m|
    puts '------------------------------------------'
    puts ' ' + Time.now.to_s
    puts ' Generating README.html'
    puts '------------------------------------------'
    puts "TODO: #{m[0]} changed"
    `grip --export #{m[0]}`
  end
end
