# encoding: UTF-8
class Employee < ActiveRecord::Base

  validates_length_of :first_name, :within => 1..30
  validates_length_of :last_name, :within => 1..30

  has_many :transaction_entries

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.find_active_employees
    # modifiable array
    employees = Array.new
    employees += Rails.cache.fetch('Employee.all') { Employee.find(:all, :order => "last_name, first_name", :conditions => 'is_active = true') }

    return employees
  end
end
