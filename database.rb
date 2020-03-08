require 'active_record'
require 'dotenv/load'
require './models/item'
require './models/payslip'

ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  database: ENV['DB_DATABASE'],
  host: ENV['DB_HOST'],
  username: ENV['DB_USERNAME'],
  password: ENV['DB_PASSWORD']
)
Time.zone_default = Time.find_zone! 'Tokyo'
ActiveRecord::Base.default_timezone = :local
