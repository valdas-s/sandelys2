require File.dirname(__FILE__) + '/../test_helper'

class EmployeeTest < Test::Unit::TestCase
  fixtures :employees

  def test_model
    e = Employee.find(employees(:jonas).id)
    assert_equal employees(:jonas).id, e.id
    assert_equal employees(:jonas).first_name, e.first_name
    assert_equal employees(:jonas).last_name, e.last_name
    assert_equal employees(:jonas).occupation, e.occupation
    assert_equal employees(:jonas).is_active, e.is_active
    assert_equal employees(:jonas).first_name + " " + employees(:jonas).last_name, e.full_name
  end

  # Replace this with your real tests.
  def test_validations
    e = Employee.new
    assert !e.valid?

    e.first_name = ""
    e.last_name = "a"
    assert !e.valid?

    e.first_name = "a"
    e.last_name = ""
    assert !e.valid?

    e.first_name = "a"
    e.last_name = "1234567890123456789012345678901"
    assert !e.valid?

    e.first_name = "1234567890123456789012345678901"
    e.last_name = "a"
    assert !e.valid?

    e.first_name = "a"
    e.last_name = "a"
    assert e.valid?

  end

  def test_inactive
    c1 = c2 = c3 = 0
    Employee.find_active_employees.each {|e| c1 += 1}
    Employee.find(:all).each {|e| c2 += 1}
    Employee.find_all_by_is_active(false).each {|e| c3 += 1}

    assert c1 < c2
    assert_equal c2, c1 + c3
  end

  def test_column_names
    assert_equal "Vardas", Employee.human_attribute_name("first_name")
    assert_equal "Id", Employee.human_attribute_name("id")
  end
end
