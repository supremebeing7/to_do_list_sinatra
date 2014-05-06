require 'sinatra'
require 'thin'
require 'haml'
require 'data_mapper'
require 'binding_of_caller'
require 'better_errors'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")
class Task
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :completed_at, DateTime
end
DataMapper.finalize

configure :development do
  use BetterErrors::Middleware
  # you need to set the application root in order to abbreviate filenames
  # within the application:
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

get '/' do
  @tasks = Task.all
  haml :index
end

get '/:task' do
  @task = params[:task].split('-').join(' ').capitalize
  haml :task
end

post '/' do
  @task = Task.create(params[:task])
  redirect to('/')
end

delete '/task/:id' do
  Task.get(params[:id]).destroy
  redirect to('/')
end

put '/task/:id' do
  @task = Task.get(params[:id])
  @task.completed_at = @task.completed_at.nil? ? Time.now : nil
  @task.save
  redirect to('/')
end
