require 'json'
require 'haml'
require 'sinatra'

require_relative 'fare_options'

get '/' do
  haml :index
end

get '/sample' do
  haml :sample
end

post '/compute' do
  data = JSON.parse(request.body.read)
  FareOptions.new.compute(data).all.to_json
end
