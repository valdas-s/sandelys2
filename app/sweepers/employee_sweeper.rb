# encoding: UTF-8
class EmployeeSweeper < ActionController::Caching::Sweeper
  observe Employee

  def after_create(employee)
    expire_employee_cache
  end
  
  def after_update(employee)
    expire_employee_cache
  end
  
  def after_destroy(employee)
    expire_employee_cache
  end
          
  private
  def expire_employee_cache
    Rails.cache.delete('Employee.all')
  end
end