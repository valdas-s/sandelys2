# encoding: UTF-8
class TransientRecord < ActiveRecord::Base

  def initialize(attributes=nil)
    super
    # Explicit assignment of the id attribute is necessary because the default
    # ActiveRecord (1.0.0) behavior is to omit id from the @attributes hash
    # when a new record is instantiated. Until the id entry is added to
    # @attributes with an explicit assignment it won't be processed by the
    # attributes or attributes= methods.
    self.id = nil if self.class.columns_hash['id']
    self.attributes = attributes if attributes
  end

  def self.columns()
    @columns ||= [];
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(
                    name.to_s, default, sql_type.to_s, null)
  end

  # Because super does not process id attribute (see note in initialize).
  def attributes=(attributes)
    attributes.each { |k,v| self[k] = v }
  end

end