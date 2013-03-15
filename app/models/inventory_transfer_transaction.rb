# encoding: UTF-8
class InventoryTransferTransaction < InventoryTransaction
  has_one :assign_entry, :class_name=>"AssignEntry", :foreign_key => "inventory_transaction_id", :dependent => :destroy
  has_one :remove_entry, :class_name=>"RemoveEntry", :foreign_key => "inventory_transaction_id", :dependent => :destroy

  attr_accessor :to_account_id, :from_account_id, :to_employee_id, :from_employee_id

  validates_presence_of :from_account_id, :to_account_id
  validates_presence_of :from_employee_id

  def validate
    super
    if errors.count == 0
      max_amount = inventory_item.amount_for_employee_and_account_and_date(Employee.find(from_employee_id), Account.find(from_account_id), transaction_date)
      errors.add(:inventory_amount, " yra per didelis &mdash; asmuo sąskaitoje turi tik " + max_amount.to_s + " vienetus(-ą)") unless inventory_amount.to_f <= max_amount
    end
  end

  def action_name
    "Pervedimas"
  end

  def action_account
    remove_entry.account.number + " -> " + assign_entry.account.number
  end

  def action_employee
    remove_entry.employee.full_name + " -> " + assign_entry.employee.full_name
  end

  def action_amount
    assign_entry.inventory_amount
  end

  def item
    assign_entry.inventory_item
  end
end