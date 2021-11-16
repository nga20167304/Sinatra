# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'
require 'pg'

# connect to postgresql
connection = PG.connect dbname: 'sinatra_development', user: 'postgres', password: ''
connection.exec "CREATE TABLE IF NOT EXISTS memos(id SERIAL PRIMARY KEY, title VARCHAR(20), body TEXT);"

get '/' do
  @title = 'main'
  results = connection.exec 'SELECT * FROM memos ORDER BY memos.id ASC'
  @memos = results.entries.map { |memo| memo.transform_keys(&:to_sym) }
  erb :index
end

# to create page
get '/memos/new' do
  @title = 'メモを追加'
  erb :create
end

# show memo contents
get '/memos/:id' do
  @title = 'メモを表示'
  sql = "SELECT * FROM memos WHERE id = $1;"
  result = connection.exec_params(sql, [params[:id]])
  @memo = result.first.transform_keys(&:to_sym)
  erb :show
end

# creating process
post '/memos' do
  @title = 'メモを追加'
  sql = "INSERT INTO memos(id, title, body) VALUES (DEFAULT, $1, $2);"
  connection.exec_params(sql, [params[:title], params[:body]])
  redirect '/'
end

# deleting process
delete '/memos/:id' do
  @title = 'メモを削除'
  sql = "DELETE FROM memos WHERE memos.id = $1;"
  connection.exec_params(sql, [params[:id]])
  redirect '/'
end

# to editer page.
get '/memos/:id/edit' do
  @title = 'メモを修正'
  sql = "SELECT * FROM memos WHERE id = $1;"
  result = connection.exec_params(sql, [params[:id]])
  @memo = result.first.transform_keys(&:to_sym)
  erb :edit
end

# editing process
patch '/memos/:id' do
  @title = 'メモを修正'
  sql = "UPDATE memos SET title = $1, body = $2 WHERE memos.id = $3;"
  connection.exec_params(sql, [params[:title], params[:body], params[:id]])
  redirect '/'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
