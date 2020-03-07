Dir["#{File.dirname(__FILE__)}/pdf/*.pdf"].sort.each do |path|
  puts path
  basename = File.basename(path, '.pdf')
  `pdftohtml -c #{path} html/#{basename}`
end