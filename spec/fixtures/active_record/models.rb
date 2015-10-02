class User < ActiveRecord::Base
  has_changelogs
  
  def my_condition
    true
  end
end

class OnlyName < User
  has_changelogs only: :name
end

class IgnoreName < User
  has_changelogs ignore: :name
end

class IfTrue < User
  has_changelogs if: :my_condition
end

class UnlessTrue < User
  has_changelogs unless: :my_condition
end
