require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"

require_relative "database.rb"

configure do
  enable :sessions
  set :session_secret, "4ac7112186f3066c0d5aa40ae1a2a90f7444b1a4daf731d40ec86abb657208ae"
  # set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database.rb"
end

def invalid_input?(text)
  text.strip.empty?
end

before do
  @storage = DatabasePersistence.new
end

post "/add" do
  name = params["name"]
  purchase_price = params["buy_price"].to_f
  sell_price = params["sell_price"].to_f

  if invalid_input?(name)
    session[:error] = "Enter a valid name for your item."
    redirect "/add"
  else
    @storage.add_item(name, purchase_price, sell_price)
    redirect "/list"
  end
end

post "/search/result" do
  if params["search_name"]
    redirect "/search/name/#{params["search_name"]}"
  elsif params["search_purchase_price"]
    redirect "/search/purchase_price/#{params["search_purchase_price"]}"
  elsif params["search_sell_price"]
    redirect "/search/sell_price/#{params["search_sell_price"]}"
  end
end

get "/update/:id" do
  @item = @storage.search_item("id", params[:id])
  erb :update_item
end

post "/update/:id" do
  @storage.update_name(params[:id], params[:name]) unless params[:name].empty?
  @storage.update_purchase_price(params[:id], params[:buy_price]) unless params[:buy_price].empty?
  @storage.update_sell_price(params[:id], params[:sell_price]) unless params[:sell_price].empty?
  session[:success] = "Your item has been updated."
  redirect "/list"
end

post "/delete/:id" do
  session[:error] = "Item deleted."
  @storage.delete_item(params[:id])
  redirect "/list"
end

# handling the case where no query is given to the search
get "/search/:field/" do
  session[:error] = "You did not enter a search field."
  redirect "/search"
end

get "/search/:field/:query" do
  @items = @storage.search_item(params[:field], params[:query])
  if @items.nil?
    session[:error] = "Could not locate item details"
    redirect "/search"
  else
    session[:success] = "Results found"
    erb :lists
  end
end

get "/" do
  erb :main_menu
end

get "/list" do
  @items = @storage.load_all_items
  erb :lists
end

get "/add" do
  erb :add
end

get "/search" do
  erb :search
end

get "/profit" do
  @profit = @storage.find_profit
  erb :profit
end


