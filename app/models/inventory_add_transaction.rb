# encoding: UTF-8
class InventoryAddTransaction < InventoryTransaction
  has_one :assign_entry, :class_name=>"AssignEntry", :foreign_key => "inventory_transaction_id", :dependent => :destroy

  attr_accessor :account_id, :employee_id

  def action_name
    "Pajamavimas"
  end

  def action_account
    assign_entry.account.number
  end

  def action_employee
    assign_entry.employee.full_name
  end

  def action_amount
    assign_entry.inventory_amount
  end

  def item
    assign_entry.inventory_item
  end
end