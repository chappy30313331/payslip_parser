require 'json'
require_relative './parser/f_parser'

results = Dir["#{File.dirname(__FILE__)}/html/*.html"].sort.map do |path|
  next unless path =~ /.*\-1\.html/
  puts path
  FParser.parse(path)
end.compact

File.open('results.json', 'w') do |f|
  f.write(JSON.pretty_generate(results))
end
