require 'sinatra'
require 'haml'
require 'pony'
require './door.rb'

PASSWORD = "opensesame"
OFFICE_COORDS = [37.5552956, -77.4582119]
DISTANCE_THRESHOLD_IN_MILES = 0.1
DOOR_UNLOCK_DURATION_IN_SECONDS = 5

set :haml, :format => :html5

get '/' do
  haml :index
end

get '/knock-knock' do
  haml :whos_there
end

post '/let-me-in' do
  begin
    if valid_request?(params[:password]) #, params[:latitude], params[:longitude])
      Thread.abort_on_exception = true

      Thread.new {
        begin
          Door.unlock! 
          sleep(DOOR_UNLOCK_DURATION_IN_SECONDS)
          Door.lock!
        rescue Exception => e
          handle e
        end
      }

      haml :come_on_in, :layout => false
    else
      Door.lock!
      haml :gtfo
    end
  rescue Exception => e
    handle e
  end
end

post '/lock-the-door' do
  Door.lock!
  haml :index
end

def valid_request?(password, lat = nil, long = nil)
  (password == PASSWORD) 
  # && (Geocoder::Calculations.distance_between(OFFICE_COORDS, [lat, long]) < DISTANCE_THRESHOLD_IN_MILES)
end

def details_for e
  backtrace_list = e.backtrace.map { |line| "* #{line}" }.join("\n")

  "An exception was encountered: #{e.message}\n#{backtrace_list}"
end

def report! exc
  Pony.mail :to      => "jeremy6d@gmail.com", 
            :from    => "lockety-lock-lock@804rva.com", 
            :subject => "Exception encountered", 
            :body    => details_for(exc)
end

def handle exc
  puts "\n\n" + details_for(exc)
  Door.lock!
  report! exc
end