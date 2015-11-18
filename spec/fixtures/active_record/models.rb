class User < ActiveRecord::Base
  has_changelogs

  def my_condition
    name == "True Condition"
  end
end

class LogEverythingUser < User
  has_changelogs ignore: [:type, :id]
end

class OnlyName < User
  has_changelogs only: :name
end

class IgnoreName < User
  has_changelogs ignore: :name
end

class IfCondition < User
  has_changelogs if: :my_condition
end

class UnlessCondition < User
  has_changelogs unless: :my_condition
end

class WithPassportsUser < LogEverythingUser
  has_many :passports, foreign_key: :user_id
end

class WithMetadataUser < LogEverythingUser
  def log_metadata
    {"hello" => "world"}
  end
end

class Passport < ActiveRecord::Base
  belongs_to :user, class_name: "WithPassportsUser"
  has_changelogs at: :user
end
