require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    columns =  DBConnection.execute2(<<-SQL)
  SELECT
    *
  FROM
    #{table_name}
SQL
    columns[0].map(&:to_sym)
    # ...
  end

  def self.finalize!
    columns.each do |col|
      col_set = (col.to_s + "=").to_sym
      define_method(col_set) do |val|
        self.attributes[col] = val
      end
    end
    columns.each do |col|
      define_method(col) do
        self.attributes[col]
      end
    end

  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    # @table_name

    @table_name ||= self.to_s.tableize

  end

  def self.all
    # ...
    results = DBConnection.execute(<<-SQL)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}

  SQL
  parse_all(results)
  end

  def self.parse_all(results)
    # ...

    results.map do |hash|
      self.new(hash)
    end

  end

  def self.find(id)
    # self.all.find { |obj| obj.id == id }
    # ...
    results = DBConnection.execute(<<-SQL, id)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    WHERE
      #{table_name}.id = ?
    LIMIT
      1

    SQL
    parse_all(results).first
    # result = results.first
  end

  def initialize(params = {})
    # ...
    params.each do |k,v|
      # symb = k.to_sym
      # byebug
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k.to_sym)

      self.send("#{k}=".to_sym, v)
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    attr_values = {}
    self.class.columns.map do |column|
      attr_values[column] = self.send(column)
    end
    attr_values.values

  end

  def insert
    # ...
    # p columns.inspect
    # p columns.inspect
    # p columns.inspect
    col_names = self.class.columns[1..-1]
    n = col_names.length
    col_names = col_names.join(", ")
    question_marks = (["?"] * n).join(", ")
    atribs = attribute_values[1..-1]

    results = DBConnection.execute(<<-SQL, *atribs)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})

  SQL

  self.id = DBConnection.last_insert_row_id

  end



  def update
    # ...
    col_names = self.class.columns[1..-1]
    n = col_names.length
    set_line = self.class.columns
      .map { |attr| "#{attr} = ?" }.join(", ")
    atribs = attribute_values

    results = DBConnection.execute(<<-SQL, *atribs, id)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_line}
    WHERE
      #{self.class.table_name}.id = ?

  SQL

  end

  def save
    # ...
    if self.id.nil?
      insert
    else
      update
    end
  end
end
