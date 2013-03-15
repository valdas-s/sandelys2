# encoding: UTF-8
class RemovedInventoryReportForm < TransientRecord
  column :start_date
  column :end_date
  column :account_id
  column :first_time

  validates_date :start_date
  validates_date :end_date

end