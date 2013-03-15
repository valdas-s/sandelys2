# encoding: UTF-8
class ReportsController < ApplicationController
  layout "layouts/standard"

  def index
    select
    render :action => 'select'
  end

  def select
    prepare_reports
  end

  def inventory_by_period_report_form
    @tab_id = 0
    prepare_reports
    @report = InventoryByPeriodReportForm.new(params[:report])
    if @report.year_and_month == nil
      render :partial => "inventory_by_period_report_form"
    else
    render :text => redirect_url_for("inventory_by_period_report?year=#{@report.year}&month=#{@report.month}&account_id=#{@report.account_id}")
    end
  end

  def inventory_by_period_report
    # Report structure: @report[:account][:inventory_item][:start_date | :end_date] = amount
    # For summary reports: @report["totals"] [:start_date | :end_date | :items_added | :items_removed]
    @report = Hash.new

    @page_title = STR_INVENTORY_BY_PERIOD_REPORT
    @start_date = Date.new(params[:year].to_i, params[:month].to_i)
    @end_date   = @start_date >> 1

    @accounts = (params[:account_id].empty?) ? RegularAccount.sorted_accounts_list : [Account.find_by_id(params[:account_id]) ]
    @inventory_items = InventoryItem.find(:all, :order => "name")

    items_hash = hash_by_id(@inventory_items)

    @report["totals"] = {@start_date => 0.0, @end_date => 0.0, "items_added" => 0.0, "items_removed" => 0.0 }
    @accounts.each do |a|
      @report[a] = {@start_date => 0.0, @end_date => 0.0, "items_added" => 0.0, "items_removed" => 0.0 }

      # inventory amounts before period
      InventoryItem.report_amounts_for(:account_id => a.id, :report_date => @start_date).each do |line|
        @report[a][items_hash[line["item_id"].to_s]] = Hash.new
        @report[a][items_hash[line["item_id"].to_s]][@start_date] = line["summary_amount"].to_f
        @report[a][@start_date] += line["summary_amount"].to_f * items_hash[line["item_id"].to_s].unit_price
      end

      # inventory amounts after period
      InventoryItem.report_amounts_for(:account_id => a.id, :report_date => @end_date).each do |line|
        @report[a][items_hash[line["item_id"].to_s]][@end_date] = line["summary_amount"].to_f
        @report[a][@end_date] += line["summary_amount"].to_f * items_hash[line["item_id"].to_s].unit_price
      end

      # inventory added within period
      InventoryItem.report_inventory_added_for_account_and_period(a, @start_date, @end_date).each do |line|
        @report[a][items_hash[line["item_id"].to_s]]["items_added"] = line["summary_amount"].to_f
        @report[a]["items_added"] += line["summary_amount"].to_f * items_hash[line["item_id"].to_s].unit_price
      end

      # inventory removed within period
      InventoryItem.report_inventory_removed_for_account_and_period(a, @start_date, @end_date).each do |line|
        @report[a][items_hash[line["item_id"].to_s]]["items_removed"] = line["summary_amount"].to_f.abs
        @report[a]["items_removed"] += line["summary_amount"].to_f.abs * items_hash[line["item_id"].to_s].unit_price
      end

      # Calculate totals
      @report["totals"][@start_date] += @report[a][@start_date]
      @report["totals"][@end_date] += @report[a][@end_date]
      @report["totals"]["items_added"] += @report[a]["items_added"]
      @report["totals"]["items_removed"] += @report[a]["items_removed"]
    end

  end

  def inventory_by_date_report_form
    @tab_id = 1
    prepare_reports
    @report = InventoryByDateReportForm.new(params[:report])
    if @report.first_time != nil && @report.valid?
      render :text => redirect_url_for("inventory_by_date_report?date=#{@report.date}")
    else
      render :partial => "inventory_by_date_report_form"
    end
  end

  def inventory_by_date_report
    @report_date = parse_date(params[:date])
    @page_title = STR_INVENTORY_BY_DATE_REPORT

    @accounts = Account.find(:all, :order => "number")
    @inventory_items = InventoryItem.find(:all, :order => "name")

    # Report structure: @report[:account][:inventory_item] = amount
    @report = Hash.new

    items_hash = hash_by_id(@inventory_items)

    @accounts.each do |a|
      @report[a] = {}

      # inventory amounts before period
      InventoryItem.report_amounts_for(:account_id => a.id, :report_date => @report_date).each do |line|
        @report[a][items_hash[line["item_id"].to_s]] = line["summary_amount"].to_f
      end
    end
  end

  def inventory_by_employee_report_form
    @tab_id = 2
    prepare_reports
    @report = InventoryByEmployeeReportForm.new(params[:report])
    if @report.first_time != nil && @report.valid?
      render :text => redirect_url_for("inventory_by_employee_report?date=#{@report.date}&employee_id=#{@report.employee_id}")
    else
      render :partial => "inventory_by_employee_report_form"
    end
  end

  def inventory_by_employee_report
    @page_title = STR_INVENTORY_BY_EMPLOYEE_REPORT
    @report_date = parse_date(params[:date])

    @employees = (params[:employee_id].empty?) ? Employee.find_active_employees : [Employee.find_by_id(params[:employee_id]) ]
    @accounts = Account.find(:all, :order => "number")
    @inventory_items = InventoryItem.find(:all, :order => "name")
    items_hash = hash_by_id(@inventory_items)

    @report = {}
    @employees.each do |employee|
      @report[employee] = {"total" => 0.0}
      @accounts.each do |account|
        @report[employee][account] = {"total" => 0.0}
        InventoryItem.report_amounts_for(:account_id => account.id, :employee_id => employee.id, :report_date => @report_date).each do |line|
          # Number of inventory items for account and employee
          @report[employee][account][items_hash[line["item_id"].to_s]] = line["summary_amount"].to_f
          # Total account value sum(inventory_amount * inventory_price) for an account
          @report[employee][account]["total"] += line["summary_amount"].to_f * items_hash[line["item_id"].to_s].unit_price
        end
        # Total value of an inventory for employee
        @report[employee]["total"] += @report[employee][account]["total"]
      end
    end
  end

  def inventory_by_account_report_form
    @tab_id = 3
    prepare_reports
    @report = InventoryByAccountReportForm.new(params[:report])
    if @report.year_and_month == nil
      render :partial => "inventory_by_account_report_form"
    else
    render :text => redirect_url_for("inventory_by_account_report?year=#{@report.year}&month=#{@report.month}&account_id=#{@report.account_id}")
    end
  end

  def inventory_by_account_report
    @page_title = STR_INVENTORY_BY_ACCOUNT_REPORT
    @start_date = Date.new(params[:year].to_i, params[:month].to_i)
    @end_date   = @start_date >> 1

    @accounts = (params[:account_id].empty?) ? Account.find(:all, :order => "number") : [Account.find_by_id(params[:account_id]) ]
    @employees = Employee.find(:all, :order => "last_name, first_name")

    accounts_hash = hash_by_id(@accounts)
    employees_hash = hash_by_id(@employees)

    # Initialize @report hash
    @report = {"totals" => {"start_date" => 0.0, "end_date" => 0.0, "total_received" => 0.0, "total_removed" => 0.0} }
    @accounts.each do |account|
      @report[account] = {"totals" => {"start_date" => 0.0, "end_date" => 0.0, "total_received" => 0.0, "total_removed" => 0.0} }
      @employees.each do |employee|
        @report[account][employee] = {"start_date" => 0.0, "end_date" => 0.0, "total_received" => 0.0, "total_removed" => 0.0}
      end
    end

    InventoryItem.report_summary_amounts_for_account_and_employee(@start_date).each do |line|
      next if accounts_hash[line["account_id"]] == nil
      amount = line["summary_value"].to_f
      @report[accounts_hash[line["account_id"]]][employees_hash[line["employee_id"]]]["start_date"] = amount
      @report[accounts_hash[line["account_id"]]]["totals"]["start_date"] += amount
      @report ["totals"]["start_date"] += amount
    end

    InventoryItem.report_summary_amounts_for_account_and_employee(@end_date).each do |line|
      next if accounts_hash[line["account_id"]] == nil || employees_hash[line["employee_id"]] == nil
      amount = line["summary_value"].to_f
      @report[accounts_hash[line["account_id"]]][employees_hash[line["employee_id"]]]["end_date"] = amount
      @report[accounts_hash[line["account_id"]]]["totals"]["end_date"] += amount
      @report ["totals"]["end_date"] += amount
    end

    InventoryItem.report_inventory_received_for_account_and_employee(@start_date, @end_date).each do |line|
      next if accounts_hash[line["account_id"]] == nil || employees_hash[line["employee_id"]] == nil
      amount = line["summary_value"].to_f
      @report[accounts_hash[line["account_id"]]][employees_hash[line["employee_id"]]]["total_received"] = amount
      @report[accounts_hash[line["account_id"]]]["totals"]["total_received"] += amount
      @report ["totals"]["total_received"] += amount
    end

    InventoryItem.report_inventory_removed_for_account_and_employee(@start_date, @end_date).each do |line|
      next if accounts_hash[line["account_id"]] == nil || employees_hash[line["employee_id"]] == nil
      amount = -(line["summary_value"].to_f)
      @report[accounts_hash[line["account_id"]]][employees_hash[line["employee_id"]]]["total_removed"] = amount
      @report[accounts_hash[line["account_id"]]]["totals"]["total_removed"] += amount
      @report ["totals"]["total_removed"] += amount
    end
  end

  def removed_inventory_report_form
    @tab_id = 4
    prepare_reports
    @report = RemovedInventoryReportForm.new(params[:report])
    if @report.first_time != nil && @report.valid?
      render :text => redirect_url_for("removed_inventory_report?start_date=#{@report.start_date}&end_date=#{@report.end_date}&account_id=#{@report.account_id}")
    else
      render :partial => "removed_inventory_report_form"
    end
  end

  def removed_inventory_report
    @page_title = STR_REMOVED_INVENTORY_REPORT
    @start_date = parse_date(params[:start_date])
    @end_date = parse_date(params[:end_date])

    @accounts = (params[:account_id].empty?) ? Account.find(:all, :order => "number") : [Account.find_by_id(params[:account_id]) ]
    @inventory_items = InventoryItem.find(:all, :order => "name")

    accounts_hash = hash_by_id(@accounts)
    items_hash = hash_by_id(@inventory_items)

    # Initialize report
    @report = {"totals" => 0.0}
    @accounts.each do |account|
      @report[account] = {"totals" =>  0.0 }
      @inventory_items.each do |item|
        @report[account][item] = 0.0
      end
    end

    InventoryItem.report_inventory_removed_for_period(@start_date, @end_date).each do |line|
      next if accounts_hash[line["account_id"]] == nil
      amount = -(line["summary_amount"].to_f)
      @report[accounts_hash[line["account_id"]]][items_hash[line["item_id"]]] += amount
      @report[accounts_hash[line["account_id"]]]["totals"] += amount * items_hash[line["item_id"].to_s].unit_price
      @report["totals"] += amount * items_hash[line["item_id"].to_s].unit_price
    end
  end

  private

  # Create a hash of records hash[record.id] = item
  def hash_by_id(records)
   h = {}
   records.each { |i| h[i.id.to_s] = i }
   return h
  end

  def prepare_reports
    @page_title = STR_REPORT_SELECT
    @tab_items = report_tabs
    @tab_id = 0 if @tab_id == nil

    case @tab_id
      when 0 then prepare_report_by_period
      when 1 then prepare_report_by_date
      when 2 then prepare_report_by_employee
      when 3 then prepare_report_by_account
      when 4 then prepare_removed_inventory_report
    end
    @selected_tab = @tab_items[@tab_id]
  end

  def prepare_report_by_period
    @accounts = RegularAccount.sorted_accounts_list
    @accounts.unshift(RegularAccount.new(:number=>"Visos sąskaitos"))
    d = Date.today
    @report_dates = []
    36.times do
      @report_dates << d
      d = d << 1
    end
  end

  def prepare_report_by_date
  end

  def prepare_report_by_employee
    @employees = Employee.find_active_employees
    @employees.unshift(Employee.new(:first_name=>"Visi asmenys", :last_name => ""))
  end

  def prepare_report_by_account
    d = Date.today
    @report_dates = []
    36.times do
      @report_dates << d
      d = d << 1
    end

    @accounts = RegularAccount.sorted_accounts_list
    @accounts.unshift(RegularAccount.new(:number=>"Visos sąskaitos"))
  end

  def prepare_removed_inventory_report
    @accounts = RegularAccount.sorted_accounts_list
    @accounts.unshift(RegularAccount.new(:number=>"Visos sąskaitos"))
  end

  def report_tabs
    items = Array.new
    items << TabItem.new(STR_INVENTORY_BY_PERIOD_REPORT, "inventory_by_period_report_form")
    items << TabItem.new(STR_INVENTORY_BY_DATE_REPORT, "inventory_by_date_report_form")
    items << TabItem.new(STR_INVENTORY_BY_EMPLOYEE_REPORT, "inventory_by_employee_report_form")
    items << TabItem.new(STR_INVENTORY_BY_ACCOUNT_REPORT, "inventory_by_account_report_form")
    items << TabItem.new(STR_REMOVED_INVENTORY_REPORT, "removed_inventory_report_form")

    return items
  end

  def parse_date(date)
    date_parts = date.split('-')
    return Date.new(date_parts[0].to_i, date_parts[1].to_i, date_parts[2].to_i)
  end

  def redirect_url_for(uri)
    return "<script type=\"text/javascript\">window.location=\"#{uri}\"</script>"
  end
end
