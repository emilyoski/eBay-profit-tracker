require "pg"

class DatabasePersistence
  def initialize
    @db = PG.connect(dbname: "resell")
  end

  def query(statement, *params)
    @db.exec_params(statement, params)
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

  def search_item(field, search_term)
    if field == "purchase_price"
      search_purchase_price(search_term)
    elsif field == "sell_price"
      search_sell_price(search_term)
    elsif field == "name"
      search_name(search_term)
    elsif field == "id"
      search_id(search_term)
    else
      nil
    end
  end

  def update_name(id, name)
    sql = "UPDATE items SET name = $1 WHERE id = $2"
    query(sql, name, id)
  end

  def update_purchase_price(id, price)
    sql = "UPDATE items SET purchase_price = $1::NUMERIC WHERE id = $2"
    query(sql, price.to_f, id)
  end

  def update_sell_price(id, price)
    sql = "UPDATE items SET sell_price = $1::NUMERIC WHERE id = $2"
    query(sql, price.to_f, id)
  end

  def delete_item(id)
    sql = "DELETE FROM items WHERE id = $1"
    query(sql, id)
  end

  def find_profit
    sql = "SELECT sum((sell_price - purchase_price)) AS profit FROM items 
    WHERE sell_price IS NOT NULL;"
    result = query(sql).map { |tuple| tuple["profit"] }[0]
  end

  private

  def search_purchase_price(price)
    sql = "SELECT * FROM items WHERE purchase_price = $1::NUMERIC;"
    result = query(sql, price)
    return nil if result.ntuples < 1
    convert_tuple_to_array(result)
  end

  def search_sell_price(price)
    sql = "SELECT * FROM items WHERE sell_price = $1::NUMERIC;"
    result = query(sql, price)
    return nil if result.ntuples < 1
    convert_tuple_to_array(result)
  end

  def search_name(name)
    sql = "SELECT * FROM items WHERE name ~ $1;"
    result = query(sql, name)
    return nil if result.ntuples < 1
    convert_tuple_to_array(result)
  end

  def search_id(id)
    sql = "SELECT * FROM items WHERE id = $1::NUMERIC;"
    result = query(sql, id)
    return nil if result.ntuples < 1
    convert_tuple_to_array(result)[0]
  end

  def convert_tuple_to_array(input_tuple)
    input_tuple.map do |tuple|
      [ tuple["name"], 
        tuple["purchase_price"], 
        tuple["sell_price"],
        tuple["id"] ]
    end
  end
end