# encoding: UTF-8
class TabItem
  attr_accessor :name, :form

  def initialize(name, form)
    @name = name
    @form = form
  end
end