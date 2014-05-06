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
  belongs_to :list
end

class List
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  has n, :tasks, :constraint => :destroy
end

DataMapper.finalize

configure :development do
  use BetterErrors::Middleware
  # you need to set the application root in order to abbreviate filenames
  # within the application:
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

get '/' do
  @lists = List.all(order: [:name])
  haml :index
end

get '/:task' do
  @task = params[:task].split('-').join(' ').capitalize
  haml :task
end

post '/:id' do
  List.get(params[:id]).tasks.create(params['task'])
  redirect to('/')
end

delete '/task/:id' do
  Task.get(params[:id]).destroy
  redirect to('/')
end

put '/task/:id' do
  @task = Task.get(params[:id])
  @task.completed_at = @task.completed_at.nil? ? Time.now.localtime : nil
  @task.save
  redirect to('/')
end

post '/new/list' do
  List.create(params['list'])
  redirect to('/')
end

delete '/list/:id' do
  List.get(params[:id]).destroy
  redirect to('/')
end
