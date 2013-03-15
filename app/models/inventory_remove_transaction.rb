# encoding: UTF-8
class InventoryRemoveTransaction < InventoryTransaction
  has_one :remove_entry, :class_name=>"RemoveEntry", :foreign_key => "inventory_transaction_id", :dependent => :destroy

  attr_accessor :account_id, :employee_id

  def validate
    super
    if errors.count == 0
      max_amount = inventory_item.amount_for_employee_and_account_and_date(Employee.find(employee_id), Account.find(account_id), transaction_date)
      errors.add(:inventory_amount, " yra per didelis &mdash; asmuo sąskaitoje turi tik " + max_amount.to_s + " vienetus(-ą)") unless inventory_amount.to_f <= max_amount
    end
  end

  def action_name
    "Nurašymas"
  end

  def action_account
    remove_entry.account.number
  end

  def action_employee
    remove_entry.employee.full_name
  end

  def action_amount
    -remove_entry.inventory_amount
  end

  def item
    remove_entry.inventory_item
  end
end