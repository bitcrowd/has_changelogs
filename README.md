# HasChangelogs

has_changelogs tracks changes on a model and it's associations for applications that need to have change history. The version is however, 0.2.0, so use at your own perril.

Especially a generator for the changelog model is missing - see /spec/fixtures/active_record/changelog.rb for it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'has_changelogs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install has_changelogs

## Usage

Given you had a fitting Changelog Model (see ./spec/fixtures/active_record/changelog.rb) you can do the following:

```ruby
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

class Passport < ActiveRecord::Base
  belongs_to :user, class_name: "WithPassportsUser"
  has_changelogs at: :user
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bitcrowd/has_changelogs.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

