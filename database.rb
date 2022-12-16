require "pg"

class DatabasePersistence
  def initialize
    @db = PG.connect(dbname: "resell")
  end

  def query(statement, *params)
    @db.exec_params(statement, params)
  end

  def convert_tuple_to_array(input_tuple)
    input_tuple.map do |tuple|
      [ tuple["name"], 
        tuple["purchase_price"], 
        tuple["sell_price"] ]
    end
  end

  def load_all_items
    sql = "SELECT * FROM items;"
    result = query(sql)
    convert_tuple_to_array(result)
  end

  def add_item(name, purchase_price, sell_price)
    sell_price = nil if sell_price == 0.0
    sql = "INSERT INTO items (name, purchase_price, sell_price)"\
          "VALUES($1, $2, $3);"
    query(sql, name, purchase_price, sell_price)
  end

  def load_item(field, search_term)
    if field == "purchase_price"
      sql = "SELECT * FROM items WHERE purchase_price = $1::NUMERIC;"
      result = query(sql, search_term)
      convert_tuple_to_array(result)
    elsif field == "sell_price"
      sql = "SELECT * FROM items WHERE sell_price = $1::NUMERIC;"
      result = query(sql, search_term)
      convert_tuple_to_array(result)
    elsif field == "name"
      sql = "SELECT * FROM items WHERE name ~ $1;"
      result = query(sql, search_term)
      convert_tuple_to_array(result)
    else
      nil
    end
  end
end