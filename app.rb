# The jQuery Drag Drop from:
# http://www.endyourif.com/drag-and-drop-with-ajax-example/

require 'rubygems'
require 'sinatra/base'
require 'sinatra/session'

require 'active_record'


module PostIt
  #This is automagically linked with the plural table (todos)
  class User < ActiveRecord::Base
    has_many :notes
    has_many :modes
    has_many :colours
    has_many :boards
  end

  class Board < ActiveRecord::Base
    belongs_to :user
    has_many   :modes
    has_many   :notes
  end

  class Mode < ActiveRecord::Base
    belongs_to :user
    belongs_to :board
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
    belongs_to :board
  end

  class App < Sinatra::Base
    register Sinatra::Session
    use Rack::MethodOverride
    set :public, "public"


    #Configure Modules ran when starting/restarting Server
    configure :development do
      require "sinatra/reloader"
      
      puts "Development"
      register Sinatra::Reloader
      #also_reload "models/*.rb"
      #also_reload "helpers/*.rb"

      ActiveRecord::Base.establish_connection(
        :adapter   => 'sqlite3',
        :database  => './db/postits.db'
      )
    end

    configure :test do
      puts "Test"
    end

    configure :production do
      db = ENV["DATABASE_URL"]
      if db.match(/postgres:\/\/(.*):(.*)@(.*)\/(.*)/) 
        username = $1
        password = $2
        hostname = $3
        database = $4

        ActiveRecord::Base.establish_connection(
          :adapter  => 'postgresql',
          :host     => hostname,
          :username => username,
          :password => password,
          :database => database
        )
      end
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

    #Some session setup
    set :session_fail, '/login'


    ## ROUTES ##
    # These direct web requests
    # There are 4 Restful types, POST(create), PUT(update), GET(view), DELETE(gone)

    get '/' do
      redirect '/boards'
    end

    get '/debug' do
      @users   = User.all
      @colours = Colour.all
      @modes   = Mode.all
      @notes   = Note.all

      erb :'summary'
    end


    #get '/list/?' do
    #  @user  = User.find_by_email('morgan.prior@gmail.com')
    #  @modes = @user.modes.all
    #  @notes = @user.notes.all
    #
    #      erb :'lists'
    #    end

    get '/boards?/?' do
      session! #Checks for valid session
      @user    = User.find_by_id( session[:user_id] )
      @boards  = @user.boards

      erb :'board/boards_all'
    end

    get '/board/:id/?' do
      session! #Checks for valid session
      @user    = User.find_by_id( session[:user_id] )
      @board   = @user.boards.find_by_id( params[:id] )
      @modes   = @board.modes
      @notes   = @board.notes

      erb :'lists'
    end

    get '/board/:id/edit/?' do
      session! #Checks for valid session
      @user    = User.find_by_id( session[:user_id] )
      @board   = @user.boards.find_by_id( params[:id] )

      erb :'board/board_edit'
    end

    post '/board/create' do
      session! #Checks for valid session
      @user    = User.find_by_id( session[:user_id] )
      @board   = @user.boards.create(
        :title          => params['title'],
        :read_security  => 1,
        :write_security => 1,
        :layout         => '[3]'
      )

      @board.modes.create(
        :title         => 'Notes'
      )
      @board.save

      "#{@board.id}"
    end

    ## AJAX call, to update a board 
    post '/board/:id' do
      session! #Checks for valid session
      @user                 = User.find_by_id( session[:user_id] )
      @board                = @user.boards.find_by_id( params[:id] )
      @board.title          = params['title'] if params['title']
      @board.read_security  = params['read_security'] if params['read_security']
      @board.write_security = params['write_security'] if params['write_security']
      @board.layout         = params['layout'] if params['layout']

      @board.save
    end

    ## Add a board from /board/:id/edit
    # possibility to make this an ajax call
    post '/board/:id/mode' do
      session! #Checks for valid session
      @user                 = User.find_by_id( session[:user_id] )
      @board                = @user.boards.find_by_id( params[:id] )
      @mode = @board.modes.create(
        :title => params['post']['title']
      )
      @mode.save

      redirect "/board/#{params[:id]}/edit"
    end

    post '/note/create' do
      #AJAX Note creation 
      @note             = Note.new
      @note.mode        = Mode.find_by_title( params['mode_name'] ) if params['mode_name']
      @note.title       = params['title'] if params['title']
      @note.description = params['description'] if params['description']

      @note.save

   "#{@note.id}"
    end

    post '/note/:id' do
      @note             = Note.find_by_id(params[:id])

      @note.mode        = Mode.find_by_title( params['mode_name'] ) if params['mode_name']
      @note.title       = params['title'] if params['title']
      @note.description = params['description'] if params['description']

      @note.save
    end



    ## Session User Authentication Routes
    post '/signup/?' do
      @user = User.create(
        :name  => params['post']['name'],
        :email => params['post']['email'],
        :auth  => params['post']['auth']
      )
      @user.save

      if @user
        session_start!
        session[:user_id] = @user.id
        session[:email]   = email
        session[:auth]    = params['post']['auth']

        @board = @user.boards.create(
          :title => 'Mainboard'
        )
        @board.modes.create(
          :title => 'General Notes'
        )

        redirect "/board/#{@board.id}"
      else
        redirect '/login'
      end
    end

    get '/login/?' do
      if session?
        redirect '/'
      else
        erb :'login'
      end
    end

    post '/login' do
      email = params['post']['email']

      if email
        session_start!
        session[:email]   = email
        session[:auth]    = params['post']['auth']
        @user             = User.find_by_email( email )
        session[:user_id] = @user.id
        #Allow redirect param from form
        redirect params['post']['redirect'] if params['post']['redirect']
        redirect '/'
      else
        redirect '/login'
      end
    end

    get '/logout' do
      session_end!
      redirect '/'
    end



    ## Tradional forms
    # From to create new
    #get '/note/create' do
    #  @note = Note.new
    #  @new  = true
    #  erb :'note/note_edit'
    #end

    # EDIT
    #get '/note/:id/edit' do
    #  @note = Note.find_by_id(params[:id])
    #  erb :'note/note_edit'
    #end

    # CREATE
    #post '/note/?' do 
    #  @user  = User.first
    #  mode   = @user.modes.first
    #  colour = @user.colours.first
    #  @note  = Note.create(
    #    :title       => params['post']['title'],
    #    :description => params['post']['description'],
    #    :mode_id     => mode.id,
    #    :colour_id   => colour.id
    #  )
    #  @note.save
    #  redirect '/list'
    #end

    # UPDATE
    #put '/note/:id/?' do
    #  @note = Note.find_by_id(params[:id])
    #  @note.title       = params['post']['title']
    #  @note.description = params['post']['description']
    #  #@note.mode_id     = mode.id
    #  #@note.colour_id   = colour.id

    # @note.save
    #     redirect '/list'
    #    end
    #for large apps you can:
    #load 'other_file.rb'

  end
end

if $0 == __FILE__
  PostIt::App.run!
end
