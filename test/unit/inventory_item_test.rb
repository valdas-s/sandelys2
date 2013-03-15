require File.dirname(__FILE__) + '/../test_helper'

class InventoryItemTest < Test::Unit::TestCase
  fixtures :inventory_items, :inventory_transactions, :transaction_entries

  def test_model
    i = InventoryItem.find_by_id(inventory_items(:kibiras).id)
    assert_equal inventory_items(:kibiras).id, i.id
    assert_equal inventory_items(:kibiras).name, i.name
    assert_equal inventory_items(:kibiras).code, i.code
    assert_equal inventory_items(:kibiras).measurement_unit, i.measurement_unit
    assert_equal inventory_items(:kibiras).unit_price, i.unit_price

  end

  def test_validations
    i = InventoryItem.new
    assert !i.valid?

    i.name = ""
    i.code = "code"
    i.measurement_unit="qty."
    i.unit_price = "10.0"
    assert !i.valid?

    i.name = "name"
    i.code = ""
    i.measurement_unit="qty."
    i.unit_price = "10.0"
    assert !i.valid?

    i.name = "name"
    i.code = "code"
    i.measurement_unit=""
    i.unit_price = "10.0"
    assert !i.valid?

    i.name = "name"
    i.code = "code"
    i.measurement_unit="qty."
    i.unit_price = ""
    assert !i.valid?

    i.name = "name"
    i.code = "code"
    i.measurement_unit="qty."
    i.unit_price = "abc"
    assert !i.valid?

    i.name = "name"
    i.code = "code"
    i.measurement_unit="qty."
    i.unit_price = "-5.00"
    assert !i.valid?

    i.name = "name"
    i.code = inventory_items(:kibiras).code
    i.measurement_unit="qty."
    i.unit_price = "5.00"
    assert !i.valid?

    i.name = inventory_items(:kibiras).name
    i.code = "code"
    i.measurement_unit="qty."
    i.unit_price = inventory_items(:kibiras).unit_price
    assert !i.valid?
  end

  def test_new_code_generator
    assert_equal "0004", InventoryItem.generate_new_code
  end

  def test_column_names
    assert_equal "Pavadinimas", InventoryItem.human_attribute_name("name")
    assert_equal "Id", InventoryItem.human_attribute_name("id")
  end
end
