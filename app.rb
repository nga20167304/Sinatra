# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'
require 'pg'

# connect to postgresql
memos = []
connection = PG.connect dbname: 'sinatra_development', user: 'postgres', password: ''

get '/' do
  @title = 'main'
  table_memos = connection.exec 'SELECT * FROM memos'
  table_memos.each do |memo|
    memos.push({ id: memo['id'], title: memo['title'], body: memo['body'] })
  end
  @memos = memos.uniq
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
  result = connection.exec "SELECT id, title, body FROM memos WHERE id = #{params[:id]};"
  @memo = result.first
  erb :show
end

# creating process
post '/memos' do
  @title = 'メモを追加'

  # create id for new memo_data
  key_arr = memos.map { |i| i[:id] }
  last_id = key_arr.max.to_i + 1

  connection.exec "INSERT INTO memos(id, title, body) VALUES (#{last_id}, '#{params[:title]}','#{params[:body]}') ;"

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
