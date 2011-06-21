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

## TODO ##
# Acts as lists for reordering posts
# https://rubygems.org/gems/acts_as_list

## ROUTES ##
# These direct web requests
# There are 4 Restful types, POST(create), PUT(update), GET(view), DELETE(gone)

get '/' do
 redirect '/list'
end

get '/debug' do
   @users   = User.all
   @colours = Colour.all
   @modes   = Mode.all
   @notes   = Note.all

   erb :'summary'
end


get '/list/?' do
  @user  = User.find_by_email('morgan.prior@gmail.com')
  @modes = @user.modes.all
  @notes = @user.notes.all

  erb :'lists'
end



post '/note/:id' do
  @note = Note.find_by_id(params[:id])
  @mode = Mode.find_by_title( params['mode_name'] )
  
  @note.mode = @mode 
  @note.save
end

# From to create new
get '/note/create' do
  @note = Note.new
  @new  = true
  erb :'note/note_edit'
end

# EDIT
get '/note/:id/edit' do
  @note = Note.find_by_id(params[:id])
  erb :'note/note_edit'
end

# CREATE
post '/note/?' do 
   @user  = User.first
   mode   = @user.modes.first
   colour = @user.colours.first
   @note  = Note.create(
     :title       => params['post']['title'],
     :description => params['post']['description'],
     :mode_id     => mode.id,
     :colour_id   => colour.id
   )
   @note.save
  redirect '/list'
end

# UPDATE
put '/note/:id/?' do
  @note = Note.find_by_id(params[:id])
  @note.title       = params['post']['title']
  @note.description = params['post']['description']
  #@note.mode_id     = mode.id
  #@note.colour_id   = colour.id
  
  @note.save
  redirect '/list'
end

#for large apps you can:
#load 'other_file.rb'



