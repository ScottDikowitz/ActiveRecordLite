require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    columns =  DBConnection.execute2(<<-SQL)
  SELECT
    *
  FROM
    cats
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
    arr = []
    results.map do |hash|
      p hash.inspect
      cat = self.new
      hash.each do |k,v|
        cat.send("#{k}=".to_sym, v)
      end
      arr << cat
    end
    p arr
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
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k)

      self.send("#{k}=".to_sym, v)
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    @attributes.values

  end

  def insert
    # ...
    # p columns.inspect
    # p columns.inspect
    # p columns.inspect
    col_names = self.class.columns[1..-1]
    n = col_names.length
    col_names = col_names.join(", ")
    question_marks = (["?"] * n)
    question_marks = question_marks.join(", ")
    atribs = attribute_values[1..-1]

    results = DBConnection.execute(<<-SQL, *atribs)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})

  SQL

  end

  def update
    # ...
  end

  def save
    # ...
  end
end
