# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :stadiums do
  primary_key :id
  String :stadiumname 
  String :avgrating
  String :location
end
DB.create_table! :reviews do
  primary_key :id
  foreign_key :stadiumid
  foreign_key :userid
  String :username
  String :rating
  String :review, text: true
end
DB.create_table! :users do
  primary_key :id
  String :username
  String :password
end

# Insert initial (seed) data
stadiums_table = DB.from(:stadiums)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

stadiums_table.insert(stadiumname: "Raymond James Stadium", 
                    avgrating: "9.4",
                    location: "4201 N Dale Mabry Hwy, Tampa, FL 33607")

stadiums_table.insert(stadiumname: "Tropicana Field", 
                    avgrating: "4.2",
                    location: "1 Tropicana Dr., St. Petersburg, FL 33705")

reviews_table.insert(stadiumid: "1",
                    username: "davreed", 
                    rating: "2",
                    review: "Testing comment section")

