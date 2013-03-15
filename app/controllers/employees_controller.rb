# encoding: UTF-8
class EmployeesController < ApplicationController

  layout "layouts/standard"

  cache_sweeper :employee_sweeper, :only => [:create, :update, :destroy]

  def index
    list
    render :action => 'list'
  end

  def show
  	list
	render :action => 'list'
  end

  def list
    @page_title = STR_EMPLOYEE_LIST
    @employees = Employee.paginate :order => 'last_name, first_name', :page => params[:page], :per_page => 20, :conditions => 'is_active = true'
  end

  def new
    @page_title = STR_EMPLOYEE_ADD
    @employee = Employee.new
  end

  def create
    @page_title = STR_EMPLOYEE_ADD
    @employee = Employee.new(params[:employee])
    if @employee.save
      flash[:notice] = STR_EMPLOYEE_SAVED
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @page_title = STR_EMPLOYEE_EDIT
    @employee = Employee.find(params[:id])
  end

  def update
    @page_title = STR_EMPLOYEE_EDIT
    @employee = Employee.find(params[:id])
    if @employee.update_attributes(params[:employee])
      flash[:notice] = STR_EMPLOYEE_SAVED
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def delete
    @page_title = STR_EMPLOYEE_DELETE
    @employee = Employee.find(params[:id])
  end

  def destroy
    @employee = Employee.find(params[:id])
    @employee.is_active = false
    @employee.save
	flash[:notice] = STR_EMPLOYEE_REMOVED
    redirect_to :action => 'list'
  end
end
