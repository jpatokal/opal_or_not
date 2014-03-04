require 'json'
require 'haml'
require 'sinatra'

require_relative 'models/comparison'

get '/' do
  haml :index
end

get '/faq' do
  haml :faq
end

get '/about' do
  redirect 'http://gyrovague.com/2014/02/23/sydneys-screwed-up-smartcard-or-why-i-wrote-opal-or-not/'
end

post '/compute' do
  data = JSON.parse(request.body.read)
  Comparison.new(data).compute.record.result.to_json
end
