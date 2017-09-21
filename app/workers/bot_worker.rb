require 'headless'
class BotWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(user_id, url)

    Capybara.default_max_wait_time = 30
    placements_number = 4
    puts 'This is bot for ad placement on myTarget service.'
    environment = '2'
    headless = Headless.new
    headless.start
    session = Capybara::Session.new(:selenium)
    bot = Bot.new(user_id, url, environment, session)    
    bot.authenticate_user
    bot.create_app
    bot.create_placements(placements_number)
    bot.finish_work
    headless.destroy   
  end
end
