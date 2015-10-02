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
  end
end