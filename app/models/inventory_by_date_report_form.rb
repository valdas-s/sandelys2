# encoding: UTF-8
class InventoryByDateReportForm < TransientRecord
  column :date
  column :first_time

  validates_date :date

end