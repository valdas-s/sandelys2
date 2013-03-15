# encoding: UTF-8
class InventoryItemController < ApplicationController
#  scaffold :inventory_item

  layout "layouts/standard"

  def list
    @page_title = STR_INVENTORY_LIST
    @item_filter = find_item_filter
    @accounts = [RegularAccount.new(:number => "Visos sąskaitos")].concat(RegularAccount.sorted_accounts_list)
	
    @inventory_items = paged_inventory_list_with_filter params[:page]
  end

  def set_filter
    session[:item_filter] = ItemFilter.new(params[:item_filter])
    redirect_to(:action => 'list')
  end

  def reset_filter
    @page_title = STR_INVENTORY_LIST
    session[:item_filter] = ItemFilter.new(params[:item_filter])
    redirect_to(:action => 'list')
  end

  def inventory_items_starting_with
    # no longer 'starting with' - containing a phrase
    inventory_filter_str = '%' + params[:item_filter][:item_name] + '%';
    @items = InventoryItem.find(:all, :conditions => [ 'upper(name) like upper(?)', inventory_filter_str ], :order => 'name ASC',  :limit => 8)
    render :partial => "autocomplete_item_name_filter"
  end

  def new
    @page_title = STR_INVENTORY_ADD

    @accounts = RegularAccount.sorted_accounts_list
    @employees = Employee.find_active_employees
    @add_transaction = InventoryAddTransaction.new
    @inventory_item = InventoryItem.new
    @inventory_item.code = InventoryItem.generate_new_code
  end

  def create
    @page_title = STR_INVENTORY_ADD
    @add_transaction = InventoryAddTransaction.new(params[:add_transaction])
    @inventory_item = InventoryItem.new(params[:inventory_item])

    if @inventory_item.valid? && @add_transaction.valid?
      InventoryItem.create_inventory(@inventory_item, @add_transaction)
      flash[:notice] = STR_INVENTORY_SAVED
      redirect_to :action => 'list'
    else
      @accounts = RegularAccount.sorted_accounts_list
      @employees = Employee.find_active_employees
      render :action => 'new'
    end
  end

  def edit
    @page_title = STR_INVENTORY_EDIT
    @inventory_item = InventoryItem.find(params[:id])
  end

  def update
    @page_title = STR_INVENTORY_EDIT
    @inventory_item = InventoryItem.find(params[:inventory_item][:id])
    if @inventory_item.update_attributes(params[:inventory_item])
      flash[:notice] = STR_INVENTORY_SAVED
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def delete
    @page_title = STR_INVENTORY_DELETE
    @inventory_item = InventoryItem.find(params[:id])
  end

  def destroy
    inventory_item = InventoryItem.find(params[:inventory_item][:id])
    InventoryItem.destroy_item_and_all_transactions(inventory_item)
    flash[:notice] = STR_INVENTORY_DELETED
    redirect_to :action => 'list'
  end

  def add
    @page_title = STR_INVENTORY_TRANSACTION_ADD
    @accounts = RegularAccount.sorted_accounts_list
    @employees = Employee.find_active_employees
    @add_transaction = InventoryAddTransaction.new
    @inventory_item = InventoryItem.find(params[:id])
    @add_transaction.account_id = params[:account_id]
  end

  def add_inventory
    @page_title = STR_INVENTORY_TRANSACTION_ADD
    @add_transaction = InventoryAddTransaction.new(params[:add_transaction])
    @inventory_item = InventoryItem.find(params[:inventory_item][:id])
    if @add_transaction.valid?
      InventoryItem.add_inventory(@inventory_item, @add_transaction)
      flash[:notice] = STR_INVENTORY_SAVED
      redirect_to :action => 'list'
    else
      @accounts = RegularAccount.sorted_accounts_list
      @employees = Employee.find_active_employees
      render :action => 'add'
    end
  end

  def transfer
    @page_title = STR_INVENTORY_TRANSACTION_TRANSFER
    @inventory_item = InventoryItem.find(params[:id])
    @accounts = RegularAccount.sorted_accounts_list
    @employees = Employee.find_active_employees
    @transfer_transaction = InventoryTransferTransaction.new
  end

  def transfer_inventory
    @page_title = STR_INVENTORY_TRANSACTION_TRANSFER
    @inventory_item = InventoryItem.find(params[:inventory_item][:id])
    @transfer_transaction = InventoryTransferTransaction.new(params[:transfer_transaction])
    @transfer_transaction.inventory_item = @inventory_item
    if @transfer_transaction.valid?
      InventoryItem.transfer_inventory(@inventory_item, @transfer_transaction)
      flash[:notice] = STR_INVENTORY_SAVED
      redirect_to :action => 'list'
    else
      @accounts = RegularAccount.sorted_accounts_list
      @employees = Employee.find_active_employees
      render :action => 'transfer'
    end
  end

  def display_transfer_accounts_list
    @transfer_transaction = InventoryTransferTransaction.new(:from_account_id => params[:from_account_id], :to_account_id => params[:to_account_id])
    @transfer_accounts = RegularAccount.find(:all, :conditions=>["id <> ?", @transfer_transaction.from_account_id], :order => "number") unless @transfer_transaction.from_account_id.blank?
    render(:layout=>false)
  end

  def display_transfer_employees_list
    @transfer_transaction = InventoryTransferTransaction.new(:from_employee_id => params[:from_employee_id], :to_employee_id => params[:to_employee_id])
    if @transfer_transaction.from_employee_id.blank?
      @transfer_employees = nil
    else
      @transfer_employees = Employee.find(:all, :conditions=>["id <> ? and is_active = true", @transfer_transaction.from_employee_id], :order => "last_name, first_name")
      @transfer_employees.unshift(Employee.new(:first_name => "- tam pačiam asmeniui -", :last_name => "")) unless params[:skip_self] == "true"
    end

    render :layout=>false
  end

  def change_owner
    @page_title = STR_INVENTORY_TRANSACTION_CHANGE_OWNER
    @inventory_item = InventoryItem.find(params[:id])
    @accounts = RegularAccount.sorted_accounts_list
    @employees = Employee.find_active_employees
    @transfer_transaction = InventoryTransferTransaction.new(params[:transfer_transaction])
  end

  def change_owner_inventory
    @page_title = STR_INVENTORY_TRANSACTION_CHANGE_OWNER
    @inventory_item = InventoryItem.find(params[:inventory_item][:id])
    @transfer_transaction = InventoryTransferTransaction.new(params[:transfer_transaction])
    @transfer_transaction.inventory_item = @inventory_item
    @transfer_transaction.to_account_id = @transfer_transaction.from_account_id

    if @transfer_transaction.valid?
      InventoryItem.transfer_inventory(@inventory_item, @transfer_transaction)
      flash[:notice] = STR_INVENTORY_SAVED
      redirect_to :action => 'list'
    else
      @accounts = RegularAccount.sorted_accounts_list
      @employees = Employee.find_active_employees
      render :action => 'change_owner'
    end
  end

  def remove
    @page_title = STR_INVENTORY_TRANSACTION_REMOVE
    @inventory_item = InventoryItem.find(params[:id])
    @accounts = RegularAccount.sorted_accounts_list
    @employees = Employee.find_active_employees
    @remove_transaction = InventoryRemoveTransaction.new(params[:remove_transaction])
  end

  def remove_inventory
    @page_title = STR_INVENTORY_TRANSACTION_REMOVE
    @inventory_item = InventoryItem.find(params[:inventory_item][:id])
    @remove_transaction = InventoryRemoveTransaction.new(params[:remove_transaction])
    @remove_transaction.inventory_item = @inventory_item

    if @remove_transaction.valid?
      InventoryItem.remove_inventory(@inventory_item, @remove_transaction)
      flash[:notice] = STR_INVENTORY_SAVED
      redirect_to :action => 'list'
    else
      @accounts = RegularAccount.sorted_accounts_list
      @employees = Employee.find_active_employees
      render :action => 'remove'
    end
  end

  def list_transactions
    @page_title = STR_INVENTORY_TRANSACTION_LIST
    @inventory_item = InventoryItem.find(params[:id])
    @transactions = InventoryTransaction.transactions_for_item(@inventory_item)
  end

  def delete_transaction
    @page_title = STR_REMOVE_TRANSACTION
    @transaction = InventoryTransaction.find_by_id(params[:id])
    @inventory_item = @transaction.item
  end

  def destroy_transaction
	transaction = InventoryTransaction.find_by_id(params[:transaction][:id])
    inventory_item = transaction.item
    InventoryTransaction.destroy(transaction.id)
	flash[:notice] = STR_INVENTORY_SAVED
    redirect_to :action => 'list_transactions', :id => inventory_item.id
  end

  private
  def find_item_filter
    return session[:item_filter] ||= ItemFilter.new
  end

  def paged_inventory_list_with_filter (page, per_page = 20)
  	statement = "select inventory_items.* from inventory_items" 
    params = Hash.new
    joins = Array.new
    conditions = Array.new

    if !@item_filter.item_name.blank?
      conditions << "upper(name) like upper(:item_name)"
      params [:item_name] = "%"+@item_filter.item_name+"%"
    end

    if !@item_filter.account_id.blank?
      joins << "inner join (select inventory_item_id, account_id, sum(inventory_amount) as amt from transaction_entries group by inventory_item_id, account_id) as amounts on inventory_items.id = amounts.inventory_item_id"
      params [:account_id] = @item_filter.account_id
      conditions << "amounts.amt > 0 and amounts.account_id = :account_id"
    end

	statement = statement + " " + joins.join(" and ") if joins.length > 0
    statement = statement + " where " + conditions.join(" and ") if conditions.length > 0

#	logger.debug "SQL statement: #{statement}\n"
    return InventoryItem.paginate_by_sql( [statement, params], :page => page, :order => 'name', :per_page => per_page)
  end
end
