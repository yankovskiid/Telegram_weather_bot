require 'rubygems'
require 'telegram/bot'
require 'logger'
require 'pry'

require_relative 'commands.rb'
require_relative 'token.rb'

def get_current_weather(city)
  options = { units: 'metric', APPID: OPEN_WEATHER_TOKEN }
  req = OpenWeather::Current.city(city, options)
  "description:#{req['weather'].first['description']}, tempreture:#{req['main']['temp_min']}"
end

flag = 0
binding.pry
Telegram::Bot::Client.run(TELEGRAM_TOKEN, logger: Logger.new(STDOUT)) do |bot|
  bot.listen do |message|
  case message.text
  when '/help'
    bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}, #{HELP_COMMANDS}")
  when '/weather_current'
    bot.api.send_message(chat_id: message.chat.id, text: WEATHER_INSTRACTION)
  when '/mem'
    flag = 1
    bot.api.send_photo(chat_id: message.chat.id, photo: Faraday::UploadIO.new('data/photo.jpg', 'image/jpeg'))
  when /\w+/
    if flag
      flag = 0
      bot.api.send_message(chat_id: message.chat.id, text: get_current_weather(message.text))
    else
      bot.api.send_message(chat_id: message.chat.id, text: WRONG_INPUT)
    end
  else
    bot.api.send_message(chat_id: message.chat.id, text: CONTENT_MESSAGE)
  end
  end
end
