# encoding: UTF-8
class RegularAccount < Account
  def self.sorted_accounts_list
    accounts = Array.new
    accounts += Rails.cache.fetch('RegularAccount.all') { RegularAccount.find(:all, :order =>"number") }
    return accounts
  end
end