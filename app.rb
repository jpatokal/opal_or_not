require 'sinatra'
require 'haml'

get '/' do
  haml :index
end

get '/sample' do
  haml :sample
end
