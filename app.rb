require 'json'
require 'haml'
require 'sinatra'

require_relative 'models/comparison'

get '/' do
  haml :index
end

get '/sample' do
  haml :sample
end

post '/compute' do
  data = JSON.parse(request.body.read)
  Comparison.new.compute(data).result.to_json
end
