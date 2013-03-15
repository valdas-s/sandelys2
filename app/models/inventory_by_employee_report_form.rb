# encoding: UTF-8
class InventoryByEmployeeReportForm < TransientRecord
  column :date
  column :employee_id
  column :first_time

  validates_date :date

end