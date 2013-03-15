# encoding: UTF-8
module InventoryItemHelper
  def edit_mode?(item)
    item.id != nil
  end
end
