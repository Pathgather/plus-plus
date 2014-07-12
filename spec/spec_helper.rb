require 'active_record'
require 'factories'
require "pry"
require 'factory_girl'
require 'plus_plus'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

load 'support/schema.rb'
require 'support/models.rb'