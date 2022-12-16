CREATE TABLE items (
  id serial PRIMARY KEY,
  name text NOT NULL,
  purchase_price numeric(6,2) NOT NULL,
  sell_price numeric(6,2)
);