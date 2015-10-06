ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :type
    t.string :name
    t.string :email
    t.string :uuid
    t.timestamps
  end

  create_table :changelogs, force: true do |t|
    t.timestamps
    t.references :logable, 		polymorphic: true, index: true
    t.string	   :log_scope
    t.string	   :log_action
    t.string     :log_origin
    t.text		   :changed_data
  end

  create_table :passports, force: true do |t|
    t.timestamps
    t.references :user
    t.string     :nationality
    t.date       :valid_until
  end
end