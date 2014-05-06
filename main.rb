require 'sinatra'
require 'thin'
require 'haml'

get '/' do
  haml :index
end

get '/:task' do
  @task = params[:task].split('-').join(' ').capitalize
  haml :task
end

post '/' do
  @task = params[:task]
  haml :task
end
