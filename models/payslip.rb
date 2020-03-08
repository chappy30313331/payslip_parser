require 'active_record'

class Payslip < ActiveRecord::Base
  has_many :items
end