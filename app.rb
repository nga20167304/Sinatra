# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'

#
# ------------ global variable -----------
#

json_file_path = 'storage/memo.json'
json_data = File.open(json_file_path) do |io|
  JSON.parse(io.read)
end

memos = json_data

# rewrite the json_data
def rewrite_json(my_hash)
  File.open('storage/memo.json', 'w') do |file|
    file.write(JSON.pretty_generate(my_hash))
  end
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

  @memo = memos[params[:id].to_s]
  erb :show
end

# creating process
post '/memos' do
  @title = 'メモを追加'

  # create id for new memo_data
  key_arr = memos.keys
  last_id = key_arr.max.to_i + 1

  # create new json data with appended new memo
  new_memo = { last_id.to_s => { 'title' => params[:title], 'body' => params[:body] } }

  json_data = json_data.merge(new_memo)

  rewrite_json(json_data)

  redirect '/'
  erb :show
end

# deleting process
delete '/memos/:id' do
  @title = 'メモを削除'

  memos.delete(params[:id].to_s)

  rewrite_json(json_data)

  redirect '/'
  erb :index
end

# to editer page.
get '/memos/:id/edit' do
  @title = 'メモを修正'
  @memo = memos[params[:id].to_s]
  erb :edit
end

# editing process
patch '/memos/:id' do
  @title = 'メモを修正'

  edit_memo = memos[params[:id].to_s]
  edit_memo['title'] = params[:title]
  edit_memo['body'] = params[:body]

  rewrite_json(json_data)

  redirect '/'
  erb :index
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
