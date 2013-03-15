# encoding: UTF-8
class InventoryByPeriodReportForm < TransientRecord
  column :year_and_month
  column :account_id

  def year
    year_and_month.split("-") [0]
  end

  def month
    year_and_month.split("-")[1]
  end
end