require File.dirname(__FILE__) + '/../test_helper'

class InventoryTransactionTest < Test::Unit::TestCase
  fixtures :accounts, :employees, :inventory_items, :inventory_transactions, :transaction_entries

  def test_model
    t = InventoryTransaction.find_by_id(inventory_transactions(:jonas_pajamuoja_kibira_i_12345).id)
    assert_equal inventory_transactions(:jonas_pajamuoja_kibira_i_12345).id, t.id
    assert_equal inventory_transactions(:jonas_pajamuoja_kibira_i_12345).transaction_date, t.transaction_date
    assert_equal inventory_transactions(:jonas_pajamuoja_kibira_i_12345).type, t.type
  end

  def test_validations
    t = InventoryTransaction.new
    assert !t.valid?

    t.transaction_date = '2006-02-29'
    t.inventory_amount = "5"
    assert !t.valid?

    t.transaction_date = '2006-02'
    t.inventory_amount = "5"
    assert !t.valid?

    t.transaction_date = nil
    t.inventory_amount = "5"
    assert !t.valid?

    t.transaction_date = '2006'
    t.inventory_amount = "5"
    assert !t.valid?

    t.transaction_date = 'a'
    t.inventory_amount = "5"
    assert !t.valid?

    t.transaction_date = '2006-01-30'
    t.inventory_amount = "-5"
    assert !t.valid?

    t.transaction_date = '2006-01-30'
    t.inventory_amount = "-a"
    assert !t.valid?

    t.transaction_date = '2006-01-30'
    t.inventory_amount = "5"
    assert t.valid?
  end

  def test_column_names
    assert_equal "Kiekis", InventoryTransaction.human_attribute_name("inventory_amount")
    assert_equal "Id", InventoryTransaction.human_attribute_name("id")
  end
end
