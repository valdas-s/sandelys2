# encoding: UTF-8
class Account < ActiveRecord::Base
  has_many :transaction_entries

  validates_length_of :number, :within => 1..30
  validates_uniqueness_of :number

end