#!/usr/bin/env ruby -w
# encoding: UTF-8

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

# See ActionController::RequestForgeryProtection for details
# Uncomment the :secret if you're not using the cookie session store
protect_from_forgery :only => [:create, :update, :destroy] # :secret => '113078d8c701830a93374d1a3d3c8c90'
 

#  before_filter :set_charset

  def set_charset
    @headers["Content-Type"] = "text/html; charset=utf-8"
  end

# Employee string constants
  STR_EMPLOYEE_LIST = "Darbuotojų sąrašas"
  STR_EMPLOYEE_ADD = "Darbuotojo duomenys"
  STR_EMPLOYEE_EDIT = "Darbuotojo duomenys"
  STR_EMPLOYEE_DELETE = "Pašalinti darbuotoją"
  STR_EMPLOYEE_SAVED = "Darbuotojo duomenys išsaugoti..."
  STR_EMPLOYEE_REMOVED = "Darbuotojas pašalintas iš sistemos..."

# Account string constants
  STR_ACCOUNT_LIST = "Sąskaitų sąrašas"
  STR_ACCOUNT_ADD = "Sąskaitos duomenys"
  STR_ACCOUNT_EDIT = "Sąskaitos duomenys"
  STR_ACCOUNT_DELETE = "Pašalinti sąskaitą"
  STR_ACCOUNT_SAVED = "Sąskaitos duomenys išsaugoti..."
  STR_ACCOUNT_REMOVED = "Sąskaita pašalinta iš sistemos..."

# Inventory string constants
  STR_INVENTORY_LIST = "Inventoriaus sąrašas"
  STR_INVENTORY_ADD = "Inventoriaus duomenys"
  STR_INVENTORY_EDIT = "Inventoriaus duomenys"
  STR_INVENTORY_DELETE = "Pašalinti inventorių"
  STR_INVENTORY_SAVED = "Inventoriaus duomenys išsaugoti..."
  STR_INVENTORY_DELETED = "Inventorius pašalintas iš sistemos..."
  STR_INVENTORY_TRANSACTION_ADD = "Pajamuoti"
  STR_INVENTORY_TRANSACTION_TRANSFER = "Pervesti"
  STR_INVENTORY_TRANSACTION_CHANGE_OWNER = "Perduoti"
  STR_INVENTORY_TRANSACTION_REMOVE = "Nurašyti"
  STR_INVENTORY_TRANSACTION_LIST = "Inventoriaus apyvarta"
  STR_REMOVE_TRANSACTION = "Pašalinti įrašą"

# Report string constants
  STR_REPORT_SELECT = "Pasirinkite ataskaitą"
  STR_INVENTORY_BY_PERIOD_REPORT = "Materialinių vertybių apskaitos ataskaita"
  STR_INVENTORY_BY_DATE_REPORT = "Ataskaita pagal datą"
  STR_INVENTORY_BY_EMPLOYEE_REPORT = "Ataskaita pagal materialiai atsakingą asmenį"
  STR_INVENTORY_BY_ACCOUNT_REPORT = "Ataskaita pagal sąskaitos numerį"
  STR_REMOVED_INVENTORY_REPORT = "Nurašytų vertybių ataskaita"
end
