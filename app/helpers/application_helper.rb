# encoding: UTF-8
# Methods added to this helper will be available to all templates in the application.

module ApplicationHelper
  MONTHS = {
    1 => "sausio",
    2 => "vasario",
    3 => "kovo",
    4 => "balandžio",
    5 => "gegužės",
    6 => "birželio",
    7 => "liepos",
    8 => "rugpjūčio",
    9 => "rugsėjo",
    10 => "spalio",
    11 => "lapkričio",
    12 => "gruodžio"
   }

  def odd_even_row
    @odd = false if @odd == nil
    @odd = !@odd
    @odd ? "odd-row" : "even-row"
  end

  def accounts_list(list)
    list.collect { |a| [a[:number], a[:id].to_s]}
  end

  def employees_list(list)
    list.collect { |e| ["#{e[:first_name]} #{e[:last_name]}", e[:id].to_s]}
  end

  def year_month_list(list)
    list.collect {|e| [year_and_month(e), "%04d-%02d" % [e.year, e.month] ]}
  end

  def year_and_month(date)
    "%04d m. %s mėn." % [date.year, MONTHS[date.month]]
  end

  def year_month_and_day(date)
    "%04d m. %s mėn. %02d d." % [date.year, MONTHS[date.month], date.mday]
  end
end
