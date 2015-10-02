require 'active_record'
require 'has_changelogs/version'

module HasChangelogs
  module ClassMethods

    def has_changelogs(options = {})
      send :include, InstanceMethods

      after_create  :record_create,  :if => :change_relevant? if !options[:on] || options[:on].include?(:create)
      before_update :record_update,  :if => :change_relevant? if !options[:on] || options[:on].include?(:update)
      after_destroy :record_destroy, :if => :change_relevant? if !options[:on] || options[:on].include?(:destroy)

      class_attribute :has_changelog_options
      self.has_changelog_options = options.dup

      [:ignore, :only].each do |k|
          has_changelog_options[k] =
            ([has_changelog_options[k]].flatten.compact || []).map &:to_s
      end

      has_many :changelogs, :class_name => '::Changelog', :as => :changelogs
    end

  end

  module InstanceMethods

    def change_relevant?
      if_condition     = self.class.has_changelog_options[:if]
      unless_condition = self.class.has_changelog_options[:unless]

      conditions_met?(if_condition, unless_condition) && object_changed_notably?
    end

    def conditions_met?(if_condition, unless_condition)
      (if_condition.blank? || if_condition.call(self)) && (unless_condition.blank? || !unless_condition.call(self))
    end

    def record_create
      log_changes(:log_action => :created)
    end

    def record_update
      log_changes(:log_action => :updated)
    end

    def record_destroy
      log_changes(:log_action => :destroyed)
    end

    def object_changed_notably?
      notable_changes.any?
    end

    def notable_changes
      only = self.class.has_changelog_options[:only]
      only.empty? ? changed_and_not_ignored : (changed_and_not_ignored & only)
    end

    def changed_and_not_ignored
      ignore = self.class.has_changelog_options[:ignore]
      changed - ignore
    end

    def log_changes(options = {})
      # changelog(options).epic_changes.create(
      #   # :epic_hero              => epic_hero!(options),
      #   # :epic_action            => epic_action!(options),
      #   # :epic_action_by_admin   => epic_action_by_admin!(options),

      #   # :epic_item              => epic_item!(options),

      #   # :epic_item_nickname     => epic_item_nickname!(options),
      #   # :epic_item_owner        => epic_item_owner!(options),

      #   # :epic_treasure          => epic_treasure!(options),
      #   # :epic_treasureguard     => epic_treasureguard!(options),
      #   # :epic_treasure_nickname  => epic_treasure_nickname!(options),

      #   # :epic_change_data        => epic_change_data!(options),
      #   # :epic_change_attributes  => epic_change_attributes!(options)
      # )
    end

    # def epic_hero!(options = {})
    #   options[:epic_hero]
    # end

    # def epic_action!(options = {})
    #   options[:epic_action] || "updated"
    # end

    # def epic_action_by_admin!(options = {})
    #   !!options[:epic_action_by_admin]
    # end

    # def log_item(options = {})
    #   options[:log_item] || self
    # end

    # def epic_item_nickname!(options = {})
    #   options[:log_item_nickname]
    # end

    # def epic_item_owner!(options = {})
    #   options[:log_item_owner]
    # end


    # def epic_treasure!(options = {})
    #   options[:epic_treasure]
    # end
    # def epic_treasure_nickname!(options = {})
    #   options[:epic_treasure_nickname]
    # end
    # def epic_treasureguard!(options = {})
    #   options[:epic_treasureguard]
    # end

    # def epic_change_data!(options = {})
    #   raw_change_data.to_json
    # end

    # def epic_change_attributes!(options = {})
    #   options[:epic_change_attributes] || raw_change_data(options).keys.join(",")
    # end

    # private

    # def raw_change_data(options = {})
    #   options[:epic_change_data] || self.changes || {}
    # end

  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end

ActiveSupport.on_load(:active_record) do
  include HasChangelogs
end
