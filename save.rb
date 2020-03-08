require 'json'
require './database'
require './parser/f_parser'

results = Dir["#{File.dirname(__FILE__)}/html/*.html"].sort.map do |path|
  next unless path =~ /.*\-1\.html/
  puts path
  FParser.parse(path)
end.compact

results.each do |result|
  payslip = Payslip.create(year: result[:year], month: result[:month], is_bonus: result[:is_bonus])
  categories = %i(total income deduction attendance other)
  categories.each do |category|
    next if result[category].nil?
    result[category].each do |k, v|
      value, unit = /(?<value>\d+(?:\.\d+)?)(?<unit>.*)/.match(v).values_at(:value, :unit)
      Item.create(payslip_id: payslip.id, category: category, key: k, value: value, unit: unit)
    end
  end
end
