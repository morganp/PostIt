# The jQuery Drag Drop from:
# http://www.endyourif.com/drag-and-drop-with-ajax-example/

require 'rubygems'
require 'sinatra'

require 'active_record'



#Configure Modules ran when starting/restarting Server
configure :development do
   puts "Development"
   ActiveRecord::Base.establish_connection(
     :adapter   => 'sqlite3',
     :database  => './db/postits.db'
   )
end

configure :test do
   puts "Test"
end

configure :production do
   puts "Production"
end

#This is automagically linked with the plural table (todos)
class User < ActiveRecord::Base
  has_many :notes
  has_many :modes
  has_many :colours
end

class Mode < ActiveRecord::Base
  belongs_to :user
  has_many :notes 
end

class Colour < ActiveRecord::Base
  belongs_to :user
  has_many :notes
end

class Note < ActiveRecord::Base
  belongs_to :user
  belongs_to :mode
  belongs_to :colour

end

#Ran on Server Error
error do
   e = request.env['sinatra.error']
   puts e.to_s
   puts e.backtrace.join("\n")
   "Application error"
end

## ROUTES ##
# These direct web requests
# There are 4 Restful types, POST(create), PUT(update), GET(view), DELETE(gone)

get '/' do
   @users   = User.all
   @colours = Colour.all
   @modes   = Mode.all
   @notes   = Note.all

   erb :'summary'
end


get '/list' do
  @user = User.find_by_email('morgan.prior@gmail.com')
  @modes = @user.modes.all
  @notes = @user.notes.all

  erb :'lists'
end

#for large apps you can:
#load 'other_file.rb'

#Note /? this makes trailing / optional, which helps keep things running smoothly
get '/todo/?' do
   #@todo = Todo.find(:all)
   #erb :'todo/todo_all'
end

get '/todo/createapi' do
   #@todo = Todo.new
  
   #msg = request.fullpath
   #msg['/todo/createapi?todo='] = ''
   #msg.gsub!('%20', ' ')

   #@todo = Todo.create(
   #   :done => false,
   #   :desc => msg
   #)

   #redirect '/todo'
end


get '/todo/create/?' do
   #This is very important/cool
   #Create a new object (but not sent to database)
   #Through the Activerecord (ORM) functions it will be initialised with the database defaults

   #The @new object can be used to determin whether the template is POST (Create) or PUT (Modify)
   #@todo = Todo.new
   #@new = true
   #erb :'todo/todo_edit'
end


post '/todo/?' do
   #@todo = Todo.create(
   #   :done => params['post']['done'],
   #   :desc => params['post']['desc']
   #)
   #Retun to view of newly created item
   #redirect '/todo/' + @todo.id.to_s
end

get '/todo/:id/edit/?' do
   #@todo = Todo.find(:first, :conditions => ["id = ?", params[:id] ])
   #erb :'todo/todo_edit'
end
   
put '/todo/:id/?' do
   #@todo = Todo.find(:first, :conditions => ["id = ?", params[:id] ])
   #@todo.done = params['post']['done']
   #@todo.desc = params['post']['desc']
   #@todo.save
   #redirect '/todo/' + params[:id]
end

get '/todo/:id/?' do
   #@todo = Todo.find(:first, :conditions => ["id = ?", params[:id] ])
   #erb :'todo/todo_one'
end



