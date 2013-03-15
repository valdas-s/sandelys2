require File.dirname(__FILE__) + '/../test_helper'

class AccountTest < Test::Unit::TestCase
  fixtures :accounts

  def test_model
    # Test account finders
    account = Account.find_by_number(accounts(:a12345).number)
    assert_equal account.id, accounts(:a12345).id
    assert_equal account.type, accounts(:a12345).type

    # Test account validation
    account = RegularAccount.new
    account.number = nil
    assert !account.valid?
    account.number = ""
    assert !account.valid?
    account.number = "1234567890123456789012345678901234567890"
    assert !account.valid?
    # Test account uniquness
    account.number = "12345"
    assert !account.valid?
    account .number = "23456"
    assert account.valid?
  end

  def test_column_names
    assert_equal "Sąskaitos numeris", Account.human_attribute_name("number")
    assert_equal "Id", Account.human_attribute_name("id")
  end
end
