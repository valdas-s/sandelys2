# encoding: UTF-8
class InventoryTransaction < ActiveRecord::Base

  validates_presence_of :transaction_date
  validates_numericality_of :inventory_amount, :greater_than => 0

  attr_accessor :inventory_amount, :inventory_item

  def inventory_amount_before_type_cast
    @inventory_amount.to_s unless @inventory_amount == nil
  end

  def self.transactions_for_item(inventory_item)
    return InventoryTransaction.find(:all,
                                     :select => "inventory_transactions.id, min(inventory_transactions.transaction_date) as transaction_date, min(inventory_transactions.type) as type, min(transaction_entries.account_id) as account_id ",
                                     :joins =>"inner join transaction_entries on transaction_entries.inventory_transaction_id = inventory_transactions.id",
                                     :conditions => ["transaction_entries.inventory_item_id = :item_id", {:item_id => inventory_item.id}],
                                     :order => "account_id, transaction_date",
                                     :group => "inventory_transactions.id")
  end

  def action_name
    ""
  end

  def action_account
    ""
  end

  def action_employee
    ""
  end

  def action_amount
    ""
  end
end
