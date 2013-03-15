# encoding: UTF-8
class TransactionEntry < ActiveRecord::Base
  belongs_to :inventory_transaction
  belongs_to :inventory_item
  belongs_to :account
  belongs_to :employee
end
