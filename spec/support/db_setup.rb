require "active_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
  end

  create_table :projects, force: true do |t|
    t.string :name
    t.integer :user_id
    t.integer :budget
  end
end

class User < ActiveRecord::Base
  has_many :projects
end

class Project < ActiveRecord::Base
  belongs_to :manager, class_name: "User", foreign_key: "user_id"
end
