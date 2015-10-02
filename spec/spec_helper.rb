$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'active_support'
require 'active_record'

require 'pry'

require 'has_changelogs'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: File.dirname(__FILE__) + '/has_changelogs.sqlite3')

load File.dirname(__FILE__) + '/fixtures/active_record/schema.rb'
load File.dirname(__FILE__) + '/fixtures/active_record/models.rb'
load File.dirname(__FILE__) + '/fixtures/shared/seeds.rb'
