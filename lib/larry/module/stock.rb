module Larry
  module Module
    class Stock
      def register(handler)
        @handler = handler

        handler.register(
          Issola::Commands::Command.new(
            key: :stock,
            description: 'Query EIC stock.',
            positional_usage: '<stock> [whale] | <whale>',
            min_pos_args: 1,
            max_pos_args: 2,
            permission: 'stock.read',
            action: method(:cmd_stock)
          )
        )

        handler.register(
          Issola::Commands::Command.new(
            key: :whale,
            description: 'Manage EIC Whales.',
            positional_usage: '<name> [arg]',
            min_pos_args: 1,
            max_pos_args: 2,
            arguments: [
              [:add,     '--add',     'Add a new whale'],
              [:remove,  '--remove',  'Remove a whale'],
              [:alias,   '--alias',   'Add whale alias'],
              [:unalias, '--unalias', 'Remove whale alias'],
            ],
            permission: 'whale.write',
            action: method(:cmd_whale)
          )
        )

        handler.register(
          Issola::Commands::Command.new(
            key: :whales,
            description: 'List EIC Whales.',
            permission: 'whale.read',
            action: method(:cmd_whales)
          )
        )
      end

      private
      def cmd_stock(event)
        event << "Stock!"
      end

      def cmd_whale(event)
        add_mode     = event.named_arguments[:add]
        remove_mode  = event.named_arguments[:remove]
        alias_mode   = event.named_arguments[:alias]
        unalias_mode = event.named_arguments[:unalias]

        if [add_mode, alias_mode, unalias_mode].count { |opt| opt } > 1
          event << 'Only one of `--add`, `--remove`, --alias`, `--unalias` may be used.'
          return false
        end

        if add_mode
          add_whale(event)
        elsif remove_mode
          remove_whale(event)
        elsif alias_mode
          add_whale_alias(event)
        elsif unalias_mode
          remove_whale_alias(event)
        else
          stock = EICStock::Sheet.new
          event << 'Known whales:'
          stock.whales.each do |whale|
            event << "- #{ whale }"
          end
        end
      end

      def add_whale(event)
        return false unless event.positional_arguments.count == 1

        name = event.positional_arguments.first
        if Whale.first(name: name)
          event << "Whale '#{ name }' exists already"
          return true
        end

        whale = Whale.create(name: name)
        event << "Sucessfully created whale '#{ whale.name }'"
        true
      end

      def remove_whale(event)
        return false unless event.positional_arguments.count == 1

        name = event.positional_arguments.first
        whale = Whale.first(name: name)
        whale = whale.identity if whale.is_alias?

        unless whale
          event << "Whale '#{ name }' does not exist"
          return true
        end

        whale.destroy
        event << "Sucessfully deleted whale '#{ whale.name }'"
        true
      end

      def add_whale_alias(event)
        return false unless event.positional_arguments.count == 2

        name, new_alias = event.positional_arguments

        whale = Whale.first(name: name)
        unless whale
          event << "Whale '#{ name }' does not exist"
          return true
        end
        identity = whale.is_alias? ? whale.identity : whale

        if aliased_whale = Whale.first(name: new_alias)
          event << "Alias '#{ new_alias }' already taken by whale #{ aliased_whale.identity.name }"
          return true
        end

        Whale.create(name: new_alias, identity: identity)

        event << "Sucessfully added alias #{ new_alias } to whale #{ identity.name }"
        true
      end

      def remove_whale_alias(event)
        return false unless event.positional_arguments.count == 1

        existing_alias = event.positional_arguments.first

        aliased_whale = Whale.first(name: existing_alias)
        unless aliased_whale
          event << "Alias '#{ existing_alias }' does not exist."
          return true
        end

        unless aliased_whale.is_alias?
          event << "'#{ existing_alias }' is not an alias, but a whale account. Use `--remove` instead."
          return true
        end

        identity = aliased_whale.identity
        aliased_whale.destroy
        event << "Sucessfully removed alias #{ existing_alias } from whale #{ identity.name }"
        true
      end

      def cmd_whales(event)
        event << 'EIC Whales:'
        Whale.identities.each do |whale|
          out = "- #{ whale.name }"
          unless whale.aliases.empty?
            out << " (#{ whale.aliases_dataset.select_map(:name).join(', ') })"
          end

          event << out
        end
      end
    end
  end
end
