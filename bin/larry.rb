$LOAD_PATH.unshift '.'

require 'bin/boot'

puts 'Starting bot'

bot = Issola::Bot.new(
  token: ENV.fetch('DISCORD_TOKEN'),
  command_prefix: '!',
  admin_users: Larry::Config::Larry::ADMIN_USERS
)

bot.register(Issola::Module::Internal.new)
bot.register(Issola::Module::Permissions.new)
bot.register(Larry::Module::Stock.new)

puts "Invite me: #{ bot.invite_url }"
bot.run
