class User < ActiveRecord::Base
  has_changelogs

  def my_condition
    name == "True Condition"
  end
end

class LogEverythingUser < User
  has_changelogs
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

