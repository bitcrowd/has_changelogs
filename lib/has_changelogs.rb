require 'active_record'
require 'has_changelogs/version'

module HasChangelogs
  module ClassMethods

    def has_changelogs(options = {})
      send :include, InstanceMethods

      after_create  :record_created if !options[:on] || options[:on].include?(:create)
      before_update :record_updated,           :if => :change_relevant? if !options[:on] || options[:on].include?(:update)
      after_destroy :record_will_be_destroyed if !options[:on] || options[:on].include?(:destroy)

      class_attribute :has_changelog_options
      self.has_changelog_options = options.dup


       has_changelog_options[:ignore] = (Array(has_changelog_options[:ignore]) | [:updated_at] ).map &:to_s
       has_changelog_options[:only]   = Array(has_changelog_options[:only]).map &:to_s

      # [:ignore, :only].each do |k|
      #     has_changelog_options[k] =
      #       ([has_changelog_options[k]].flatten.compact || []).map &:to_s
      # end

      has_many :changelogs, :class_name => '::Changelog', :as => :changelogs
    end

  end

  module InstanceMethods

    def change_relevant?
      if_condition     = self.class.has_changelog_options[:if]
      unless_condition = self.class.has_changelog_options[:unless]

      notably = object_changed_notably?
      met = conditions_met?(if_condition, unless_condition)

      relevant = met && notably
      relevant
    end

    def conditions_met?(if_condition, unless_condition)
      (if_condition.blank? || if_condition.call(self)) && (unless_condition.blank? || !unless_condition.call(self))
    end

    def notable_changes
      only = self.class.has_changelog_options[:only]
      only.empty? ? changed_and_not_ignored : (changed_and_not_ignored & only)
    end

    def changed_and_not_ignored
      ignore = self.class.has_changelog_options[:ignore]
      changed - ignore
    end

    def object_changed_notably?
      notable_changes.any?
    end

    # the actions

    def record_created
      puts "record_created"
      log_changes(:log_action => :created,   log_scope: :instance)
    end

    def record_updated
      puts "record_updated"
      log_changes(:log_action => :updated,   log_scope: :attributes)
    end

    def record_will_be_destroyed
      log_changes(:log_action => :destroyed, log_scope: :instance)
    end


    def log_changes(options = {})
      log_scope = options[:log_scope]
      wtfchanges = if (log_scope == :instance || log_scope == :attributes)
        []
      else
        []
        # get changes from options
      end

      wtfchanges.each do |change|
        log_change log_data(options, change)
      end

    end

    def log_change(options = {})
      changelog_association.create(options)
    end

    def logged_model
      self.class.has_changelog_options[:changelog_model] || self
    end

    def changelog_association
      changelog_association_name = self.class.has_changelog_options[:changelogs_association] || change_logs
      logged_model.send changelog_association_name
    end

    def log_data(options, change)

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
