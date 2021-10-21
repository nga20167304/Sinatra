# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

#
# ------------ global variable -----------
#

$json_file_path = 'storage/memo.json'
$json_data = File.open($json_file_path) do |io|
  JSON.parse(io.read)
end

memos = $json_data['memos']

# rewrite the json_data
def rewrite_json
  File.open('storage/memo.json', 'w') do |file|
    JSON.dump($json_data, file)
  end
end

#
# ----------- routing -----------
#

# root
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
  @memo = memos.select { |memo| memo['id'].to_s == params[:id].to_s }
  erb :show
end

# creating process
post '/memos' do
  @title = 'メモを追加'

  # create id for new memo_data
  last_id = 0
  memos.each do |memo|
    last_id = memo['id'].to_i + 1 if last_id <= memo['id'].to_i
  end

  # create new json data with appended new memo
  new_memo = { 'id' => last_id.to_s, 'title' => params[:title], 'body' => params[:body] }

  $json_data['memos'].push(new_memo)

  rewrite_json

  redirect '/'
  erb :show
end

# deleting process
delete '/memos/:id' do
  @title = 'メモを削除'

  num = 0
  memos.each do |memo|
    if memo['id'].to_s == params[:id].to_s
      $json_data['memos'].delete_at(num)
      break
    end
    num += 1
  end

  rewrite_json

  redirect '/'
  erb :index
end

# to editer page.
get '/memos/:id/edit' do
  @title = 'メモを修正'
  @memo = memos.select { |memo| memo['id'].to_s == params[:id].to_s }
  erb :edit
end

# editing process
patch '/memos/:id' do
  @title = 'メモを修正'
  new_memo = { 'id' => params[:id].to_s, 'title' => params[:title], 'body' => params[:body] }

  # create new data
  num = 0
  memos.each do |memo|
    if memo['id'].to_s == params[:id].to_s
      $json_data['memos'][num]['title'] = new_memo['title']
      $json_data['memos'][num]['body'] = new_memo['body']
      break
    end
    num += 1
  end

  rewrite_json

  redirect '/'
  erb :index
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def hattr(text)
    Rack::Utils.escape_path(text)
  end
end
