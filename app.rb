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
  id = params[:id]
  params = [id]
  result = connection.exec_params(sql, params)
  @memo = result.first.transform_keys(&:to_sym)
  erb :show
end

# creating process
post '/memos' do
  @title = 'メモを追加'
  connection.exec "INSERT INTO memos(id, title, body) VALUES (DEFAULT, '#{params[:title]}', '#{params[:body]}');"
  redirect '/'
end

# deleting process
delete '/memos/:id' do
  @title = 'メモを削除'
  connection.exec "DELETE FROM memos WHERE memos.id = #{params[:id]} ;"
  redirect '/'
end

# to editer page.
get '/memos/:id/edit' do
  @title = 'メモを修正'
  result = connection.exec "SELECT title, body FROM memos WHERE id = #{params[:id]};"
  @memo = result.first
  erb :edit
end

# editing process
patch '/memos/:id' do
  @title = 'メモを修正'
  connection.exec "UPDATE memos SET title = '#{params[:title]}', body = '#{params[:body]}' WHERE memos.id = #{params[:id]} ;"
  redirect '/'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
