require 'rubygems'
require 'sinatra'

set :env,  :production

require 'app'

run Sinatra::Application
