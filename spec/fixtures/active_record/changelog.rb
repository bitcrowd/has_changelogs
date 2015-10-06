class Changelog < ActiveRecord::Base
	belongs_to :logable,       polymorphic: true
  serialize  :changed_data,  JSON

end