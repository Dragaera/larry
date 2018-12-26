module Larry
  class Whale < Sequel::Model
    many_to_one :identity, class: self
    one_to_many :aliases, key: :identity_id, class: self

    dataset_module do
      # Dataset of whales which are accounts.
      def identities
        where(identity_id: nil)
      end

      # Dataset of whales which are merely aliases.
      def aliases
        exclude(identity_id: nil)
      end
    end

    def self.identity_by_name(name)
      whale = Whale.first(name: name)
      return nil unless whale

      if whale.is_alias?
        whale.identity
      else
        whale
      end
    end

    def self.alias_whale(name:, new_alias:)
      if whale = Whale.identity_by_name(new_alias)
        raise ArgumentError, "Name '#{ new_alias }' already taken by whale #{ whale.name }"
      end

      identity = Whale.identity_by_name(name)
      raise ArgumentError, "No whale with name: '#{ name }'" unless identity

      Whale.create(name: new_alias, identity: identity)
    end

    def self.remove_alias(alias_:)
      unless whale = Whale.aliases.first(name: alias_)
        raise ArgumentError, "No alias with name: '#{ alias_ }"
      end

      identity = whale.identity
      whale.destroy

      identity
    end

    def is_alias?
      !!identity
    end
  end
end
