require 'active_record'
require 'has_changelogs/version'

module HasChangelogs
  module ClassMethods

    def has_changelogs(options = {})
      send :include, InstanceMethods

      after_create   :record_created                           if !options[:on] || options[:on].include?(:create)
      before_destroy :record_will_be_destroyed                 if !options[:on] || options[:on].include?(:destroy)

      after_update   :record_updated, :if => :change_relevant? if !options[:on] || options[:on].include?(:update)

      prepare_class_options(options)

      has_many :changelogs, as: :logable
    end

    private

    def prepare_class_options(options)
      class_attribute :has_changelog_options
      self.has_changelog_options = options.dup

      has_changelog_options[:ignore]  = (Array(has_changelog_options[:ignore]) | [:updated_at, :created_at, :id] ).map &:to_s
      has_changelog_options[:only]    =  Array(has_changelog_options[:only]).map &:to_s
      has_changelog_options[:force]   =  Array(has_changelog_options[:force]).map &:to_s
    end

  end

  module InstanceMethods

    def change_relevant?
      if_condition     = self.class.has_changelog_options[:if]
      unless_condition = self.class.has_changelog_options[:unless]

      conditions_met?(if_condition, unless_condition) && object_changed_notably?
    end

    def conditions_met?(if_condition, unless_condition)
      (if_condition.blank? || if_condition.call(self)) &&
        (unless_condition.blank? || !unless_condition.call(self))
    end

    def notable_changes
      notable_attributes
    end

    def notable_attributes
      only    = self.class.has_changelog_options[:only]
      force   = self.class.has_changelog_options[:force]
      notable = only.empty? ? changed_and_not_ignored : (changed_and_not_ignored & only)
      notable + force
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
      log_change(log_action: 'created')
    end

    def record_updated
      log_change(log_action: 'updated')
    end

    def record_will_be_destroyed
      log_change(log_action: 'destroyed', changed_data: attributes)
    end

    def log_change(options = {})
      defaults = {
        log_scope:    log_scope,
        changed_data: log_data,
        log_origin:   log_origin,
        log_metadata: log_metadata }

      changelog_association.create(defaults.merge options)
    end

    def log_scope
      has_changelog_options[:at].present? ? :association : :instance
    end

    def logged_model
      if has_changelog_options[:at].present?
        send(has_changelog_options[:at])
      else
        self
      end
    end

    def log_origin
      self.class.to_s
    end

    def log_metadata
      {}
    end

    def changelog_association
      logged_model.send changelog_association_name
    end

    def changelog_association_name
      self.class.has_changelog_options[:changelogs_association] || :changelogs
    end

    def log_data(options = {})
      raw_changed_data(options).select do |key, value|
        notable_changes.include? key.to_s
      end
    end

    def raw_changed_data(options = {})
      options[:change_data] || changes || {}
    end

  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end

ActiveSupport.on_load(:active_record) do
  include HasChangelogs
end
