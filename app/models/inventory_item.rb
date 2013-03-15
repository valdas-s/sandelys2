# encoding: UTF-8
class InventoryItem < ActiveRecord::Base

  has_many :transaction_entries

  validates_presence_of :name, :code, :measurement_unit
  validates_numericality_of :unit_price, :greater_than => 0
  validates_uniqueness_of :code

  def validate
    if errors.count == 0
      other_item = InventoryItem.find(:first, :conditions => ["upper(name)=upper(:name) and unit_price = :unit_price", {:name => name, :unit_price => unit_price}])
      errors.add_to_base("Inventorius su tokiu pavadinimu ir kaina jau egzistuoja") if other_item != nil and other_item.id != id
    end
  end

  def self.create_inventory(inventory_item, add_transaction)
    transaction do
      employee = Employee.find_by_id(add_transaction.employee_id)
      account = Account.find_by_id(add_transaction.account_id)

      inventory_item.save
      add_transaction.build_assign_entry(:inventory_item => inventory_item,
                                         :account => account,
                                         :employee => employee,
                                         :inventory_amount => add_transaction.inventory_amount)
      add_transaction.save
   end
  end

  def self.add_inventory(inventory_item, add_transaction)
    transaction do
      employee = Employee.find_by_id(add_transaction.employee_id)
      account = Account.find_by_id(add_transaction.account_id)

      add_transaction.build_assign_entry(:inventory_item => inventory_item,
                                         :account => account,
                                         :employee => employee,
                                         :inventory_amount => add_transaction.inventory_amount)
      add_transaction.save
   end
  end

  def self.transfer_inventory(inventory_item, transfer_transaction)
    transaction do
      # Create account transfer entries
      from_account = Account.find_by_id(transfer_transaction.from_account_id)
      to_account = Account.find_by_id(transfer_transaction.to_account_id)
      from_employee = Employee.find_by_id(transfer_transaction.from_employee_id)
      to_employee = Employee.find_by_id(transfer_transaction.to_employee_id.blank? ? transfer_transaction.from_employee_id : transfer_transaction.to_employee_id)

      transfer_transaction.build_remove_entry(:inventory_item => inventory_item,
                                              :account => from_account,
                                              :employee => from_employee,
                                              :inventory_amount => -(transfer_transaction.inventory_amount.to_f))
      transfer_transaction.build_assign_entry(:inventory_item => inventory_item,
                                              :account => to_account,
                                              :employee => to_employee,
                                              :inventory_amount => transfer_transaction.inventory_amount)
      transfer_transaction.save
    end
  end

  def self.remove_inventory(inventory_item, remove_transaction)
    transaction do
      employee = Employee.find_by_id(remove_transaction.employee_id)
      account = Account.find_by_id(remove_transaction.account_id)

      remove_transaction.build_remove_entry(:inventory_item => inventory_item,
                                            :account => account,
                                            :employee => employee,
                                            :inventory_amount => -(remove_transaction.inventory_amount.to_f))
      remove_transaction.save
   end
  end

  def self.destroy_item_and_all_transactions(inventory_item)
    transaction do
      InventoryTransaction.transactions_for_item(inventory_item).each { |t| InventoryTransaction.destroy(t.id) }
      InventoryItem.destroy(inventory_item.id)
    end
  end

  def amount_for_account_and_date(account, date)
    result = InventoryItem.find_by_sql ["select sum(inventory_amount) as summary_amount from transaction_entries inner join inventory_transactions on transaction_entries.inventory_transaction_id = inventory_transactions.id where transaction_entries.inventory_item_id = :item_id and transaction_entries.account_id = :account_id and inventory_transactions.transaction_date <= :transaction_date", {:item_id => id, :account_id => account.id, :transaction_date =>date} ]
    (result == nil) ? 0.0 : result[0].summary_amount.to_f
  end

  def amount_for_employee_and_date(employee, date)
    result = InventoryItem.find_by_sql ["select sum(inventory_amount) as summary_amount from transaction_entries inner join inventory_transactions on transaction_entries.inventory_transaction_id = inventory_transactions.id where transaction_entries.inventory_item_id = :item_id and transaction_entries.employee_id = :employee_id and inventory_transactions.transaction_date <= :transaction_date", {:item_id => id, :employee_id => employee.id, :transaction_date =>date} ]
    (result == nil) ? 0.0 : result[0].summary_amount.to_f
  end

  def amount_for_employee_and_account_and_date(employee, account, date)
    result = InventoryItem.find_by_sql ["select sum(inventory_amount) as summary_amount from transaction_entries inner join inventory_transactions on transaction_entries.inventory_transaction_id = inventory_transactions.id where transaction_entries.inventory_item_id = :item_id and transaction_entries.employee_id = :employee_id and transaction_entries.account_id = :account_id and inventory_transactions.transaction_date <= :transaction_date", {:item_id => id, :employee_id => employee.id, :account_id => account.id, :transaction_date =>date} ]
    (result == nil) ? 0.0 : result[0].summary_amount.to_f
  end

  def self.report_inventory_added_for_account_and_period(account, start_date, end_date)
    result = InventoryItem.find_by_sql ["select inventory_items.id as item_id, coalesce(summary_amount, 0) as summary_amount from inventory_items left outer join (select te1.inventory_item_id as item_id, sum(te1.inventory_amount) as summary_amount from transaction_entries as te1 inner join inventory_transactions as it on te1.inventory_transaction_id = it.id left outer join transaction_entries as te2 on it.id = te2.inventory_transaction_id and te2.type='RemoveEntry' where te1.type = 'AssignEntry' and te1.account_id <> coalesce(te2.account_id, -1) and te1.account_id = :account_id and it.transaction_date >= :start_date and it.transaction_date < :end_date group by item_id) as summaries on inventory_items.id = summaries.item_id", {:account_id => account.id, :start_date =>start_date, :end_date => end_date} ]
    return result
  end

  def self.report_inventory_removed_for_account_and_period(account, start_date, end_date)
    result = InventoryItem.find_by_sql ["select inventory_items.id as item_id, coalesce(summary_amount, 0) as summary_amount from inventory_items left outer join (select te1.inventory_item_id as item_id, sum(te1.inventory_amount) as summary_amount from transaction_entries as te1 inner join inventory_transactions as it on te1.inventory_transaction_id = it.id left outer join transaction_entries as te2 on it.id = te2.inventory_transaction_id and te2.type='AssignEntry' where te1.type = 'RemoveEntry' and te1.account_id <> coalesce(te2.account_id, -1) and te1.account_id = :account_id and it.transaction_date >= :start_date and it.transaction_date < :end_date group by item_id) as summaries on inventory_items.id = summaries.item_id", {:account_id => account.id, :start_date =>start_date, :end_date => end_date} ]
    return result
  end

  # Returns a resultset consisting of two columns [item_id] and [summary_amount]
  # for all inventory items based on given options
  # :report_date is a required option
  def self.report_amounts_for(options)
    conditions = []

    # Always expect :report_date parameter
    conditions << "inventory_transactions.transaction_date < :report_date"

    if options.include?(:account_id)
      conditions << "transaction_entries.account_id = :account_id"
    end

    if options.include?(:employee_id)
      conditions << "transaction_entries.employee_id = :employee_id"
    end

    conditions_string = conditions.join(" and ")
    sql = "select inventory_items.id as item_id, coalesce(summary_amount, 0) as summary_amount " +
          "from inventory_items left outer join " +
            "(select transaction_entries.inventory_item_id as item_id, " +
                     "sum(transaction_entries.inventory_amount) as summary_amount " +
             "from transaction_entries inner join inventory_transactions " +
               "on transaction_entries.inventory_transaction_id = inventory_transactions.id " +
               "where #{conditions_string} group by transaction_entries.inventory_item_id) as summaries on inventory_items.id = summaries.item_id"
    result = InventoryItem.find_by_sql [sql, options]
    return result
  end

  # Returns a resultset consisting of three columns [account_id], [employee_id] and [summary_value]
  # does not return empty rows for account/employee pairs that did not have any transactions within
  # given period
  def self.report_summary_amounts_for_account_and_employee(report_date)
    result = InventoryTransaction.find_by_sql ["select transaction_entries.account_id as account_id, transaction_entries.employee_id as employee_id, sum(inventory_amount * inventory_items.unit_price) as summary_value from transaction_entries inner join inventory_transactions on transaction_entries.inventory_transaction_id = inventory_transactions.id inner join inventory_items on transaction_entries.inventory_item_id = inventory_items.id where inventory_transactions.transaction_date < :report_date group by account_id, employee_id", {:report_date => report_date}]
    return result
  end

  # Returns a resultset consisting of three columns [account_id], [employee_id] and [summary_value]
  # does not return empty rows for account/employee pairs that did not have any transactions within
  # given period
  def self.report_inventory_received_for_account_and_employee(start_date, end_date)
    result = InventoryItem.find_by_sql ["select te1.account_id as account_id, te1.employee_id as employee_id, sum(te1.inventory_amount * inventory_items.unit_price) as summary_value from transaction_entries as te1 inner join inventory_items on te1.inventory_item_id = inventory_items.id inner join inventory_transactions as it on te1.inventory_transaction_id = it.id left outer join transaction_entries as te2 on it.id = te2.inventory_transaction_id and te2.type='RemoveEntry' where te1.type = 'AssignEntry' and te1.account_id <> coalesce(te2.account_id, -1) and it.transaction_date >= :start_date and it.transaction_date < :end_date group by te1.account_id, te1.employee_id", {:start_date =>start_date, :end_date => end_date} ]
    return result
  end

  # Returns a resultset consisting of three columns [account_id], [employee_id] and [summary_value]
  # does not return empty rows for account/employee pairs that did not have any transactions within
  # given period
  def self.report_inventory_removed_for_account_and_employee(start_date, end_date)
    result = InventoryItem.find_by_sql ["select te1.account_id as account_id, te1.employee_id as employee_id, sum(te1.inventory_amount * inventory_items.unit_price) as summary_value from transaction_entries as te1 inner join inventory_items on te1.inventory_item_id = inventory_items.id inner join inventory_transactions as it on te1.inventory_transaction_id = it.id left outer join transaction_entries as te2 on it.id = te2.inventory_transaction_id and te2.type='AssignEntry' where te1.type = 'RemoveEntry' and te1.account_id <> coalesce(te2.account_id, -1) and it.transaction_date >= :start_date and it.transaction_date < :end_date group by te1.account_id, te1.employee_id", {:start_date =>start_date, :end_date => end_date} ]

    return result
  end

  # Returns a resultset consisting of three columns [account_id], [item_id] and [summary_amount]
  # does not return empty rows for account/item pairs that did not have any transactions within
  # given period
  def self.report_inventory_removed_for_period(start_date, end_date)
    result = InventoryItem.find_by_sql ["select transaction_entries.account_id as account_id, transaction_entries.inventory_item_id as item_id, sum(transaction_entries.inventory_amount) as summary_amount from transaction_entries inner join inventory_transactions on transaction_entries.inventory_transaction_id = inventory_transactions.id inner join inventory_items on transaction_entries.inventory_item_id = inventory_items.id where inventory_transactions.type = 'InventoryRemoveTransaction' and inventory_transactions.transaction_date >= :start_date and inventory_transactions.transaction_date <= :end_date group by account_id, inventory_item_id", {:start_date =>start_date, :end_date => end_date} ]
    return result
  end

  def self.generate_new_code
    result = InventoryItem.find_by_sql ["select coalesce(max(code), '0000') as max_code from inventory_items" ]
    code = result[0]["max_code"].to_i
    return "%04d" % [code + 1]
  end
end
