#require 'rubygems'
#require 'sinatra'
#set :env,  :production
#run Sinatra::Application

require 'rubygems'
require 'active_record'
require 'app'

run PostIt::App
