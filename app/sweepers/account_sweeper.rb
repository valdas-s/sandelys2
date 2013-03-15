# encoding: UTF-8
class AccountSweeper < ActionController::Caching::Sweeper
  observe Account

  def after_create(account)
    expire_account_cache
  end
  
  def after_update(account)
    expire_account_cache
  end
  
  def after_destroy(account)
    expire_account_cache
  end
          
  private
  def expire_account_cache
    Rails.cache.delete('RegularAccount.all')
  end
end