# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'
require 'pg'

# connect to postgresql
memos = []
begin
  conection = PG.connect dbname: 'sinatra_development', user: 'postgres', password: ''

  t_memos = conection.exec 'SELECT * FROM memos'

  t_memos.each do |s_memo|
    memos.push({ id: s_memo['id'], title: s_memo['title'], body: s_memo['body'] })
  end
rescue PG::Error => e
  val_error = e.message
ensure
  conection&.close
end

get '/' do
  @title = 'main'
  @memos = memos
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
  @memo = memos.find { |s| s[:id] == params[:id] }
  erb :show
end

# creating process
post '/memos' do
  @title = 'メモを追加'

  # create id for new memo_data
  key_arr = memos.map { |i| i[:id] }
  last_id = key_arr.max.to_i + 1

  begin
    conection = PG.connect dbname: 'sinatra_development', user: 'postgres', password: ''
    conection.exec "INSERT INTO memos(id, title, body) VALUES (#{last_id}, '#{params[:title]}','#{params[:body]}') ;"
  rescue PG::Error => e
    val_error = e.message
  ensure
    conection&.close
  end

  redirect '/'
end

# deleting process
delete '/memos/:id' do
  @title = 'メモを削除'

  begin
    conection = PG.connect dbname: 'sinatra_development', user: 'postgres', password: ''
    conection.exec "DELETE FROM memos WHERE memos.id = #{params[:id]} ;"
  rescue PG::Error => e
    val_error = e.message
  ensure
    conection&.close
  end

  redirect '/'
end

# to editer page.
get '/memos/:id/edit' do
  @title = 'メモを修正'
  @memo = memos.find { |s| s[:id] == params[:id] }
  erb :edit
end

# editing process
patch '/memos/:id' do
  @title = 'メモを修正'

  begin
    conection = PG.connect dbname: 'sinatra_development', user: 'postgres', password: ''
    conection.exec "UPDATE memos SET title = '#{params[:title]}', body = '#{params[:body]}' WHERE memos.id = #{params[:id]} ;"
  rescue PG::Error => e
    val_error = e.message
  ensure
    conection&.close
  end

  redirect '/'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
