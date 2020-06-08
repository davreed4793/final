# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sinatra/cookies"  
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "geocoder"                                                                    #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

stadiums_table = DB.from(:stadiums)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)


before do
    @current_user = users_table.where(:id => session[:user_id]).to_a[0]
    puts @current_user.inspect
end

get "/" do 
    @stadiums = stadiums_table.all
    puts @stadiums.inspect 
    view "stadiums"
end 

get "/stadiums/:id" do 
    @stadium = stadiums_table.where(:id => params["id"]).to_a[0]
    puts @stadium.inspect
    @reviews = reviews_table.where(:stadiumid => params["id"]).to_a
    puts @reviews.inspect 

    results = Geocoder.search(@stadium[:location])
    @lat_long = results.first.coordinates.join(",")
    puts @lat_long.inspect
    view "stadium"
end 

get "/stadiums/:id/reviews/new" do 
    @stadium = stadiums_table.where(:id => params["id"]).to_a[0]
    view "newreview"
end 

get "/stadiums/:id/reviews/create" do 
    @stadium = stadiums_table.where(:id => params["id"]).to_a[0]

    puts params.inspect
    reviews_table.insert(:stadiumid => params["id"],
                        :rating => params["rating"],
                        :username => @current_user[:username],
                        :userid => @current_user[:id],
                        :review => params["comments"])
    view "reviewsubmitted"
end 

get "/users/new" do
    view "newuser"
end

post "/users/create" do
    users_table.insert(:username => params["name"],
                       :password => BCrypt::Password.create(params["password"]))
    puts params.inspect
    view "createuser"
end

get "/logins/new" do
    view "newlogin"
end

post "/logins/create" do 
    puts params 
    username_entered = params["name"]
    password_entered = params["password"]
    user = users_table.where(:username => username_entered).to_a[0]
    if user 
        if BCrypt::Password.new(user[:password]) == password_entered
        session[:user_id] = user[:id]
    view "loginsuccess"
    else 
    view "createloginfail"
    end 
    else view "createloginfail"
    end 
end 

# Logout
get "/logout" do
    session[:user_id] = nil 
    view "/logout"
end


 