# encoding: UTF-8
class AccountsController < ApplicationController
  layout "layouts/standard"

  cache_sweeper :account_sweeper, :only => [:create, :update, :destroy]

  def index
    list
    render :action => 'list'
  end

  def show
  	list
	render :action => 'list'
  end
  
  def list
    @accounts = Account.paginate :conditions => "type = 'RegularAccount'", :per_page => 20, :page => params[:page]
    @page_title = STR_ACCOUNT_LIST
  end

  def new
    @page_title = STR_ACCOUNT_ADD
    @account = RegularAccount.new
  end

  def create
    @page_title = STR_ACCOUNT_ADD
    @account = RegularAccount.new(params[:regular_account])
    if @account.save
      flash[:notice] = STR_ACCOUNT_SAVED
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @page_title = STR_ACCOUNT_EDIT
    @account = RegularAccount.find(params[:id])
  end

  def update
    @page_title = STR_ACCOUNT_EDIT
    @account = RegularAccount.find(params[:id])
    if @account.update_attributes(params[:regular_account])
      flash[:notice] = STR_ACCOUNT_SAVED
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def delete
    @page_title = STR_ACCOUNT_DELETE
    @account = RegularAccount.find(params[:id])
  end

  def destroy
    RegularAccount.find(params[:id]).destroy
	flash[:notice] = STR_ACCOUNT_REMOVED
    redirect_to :action => 'list'
  end
end
