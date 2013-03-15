require File.dirname(__FILE__) + '/../test_helper'

class TransactionEntryTest < Test::Unit::TestCase
  fixtures :accounts, :employees, :inventory_items, :inventory_transactions, :transaction_entries

  def test_model
    assert true
  end
end
