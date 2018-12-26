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

    def is_alias?
      !!identity
    end
  end
end
