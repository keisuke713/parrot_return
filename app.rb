require 'sinatra'
require 'line/bot'
require 'byebug'

# テスト用なのでベタ書き
# 本番環境じゃちゃんと env とかしてね
CHANNEL_ID = '1653694472'
CHANNEL_SECRET = '8bb30af5d7fca0dc960f8602913cc765'
CHANNEL_TOKEN = 'k+KHJ6R8p1NWM687NRqBncviRAhHpJZFS1wigUzCHkOcjZVq61cprMCWONdgnnQT0J9PZNGWBMhb9jGCeH0/LR5r6M/U06hZ0WArNch0fOOcSLz3DmJz5xDunS+O2qV+oQ/Djhm8WCoLbqRclgr2EgdB04t89/1O/w1cDnyilFU='

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id     = CHANNEL_ID
    config.channel_secret = CHANNEL_SECRET
    config.channel_token  = CHANNEL_TOKEN
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        byebug
        message = {
          type: 'text',
          text: 'やっぱ俺って天才'
        }
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  }

  # Don't forget to return a successful response
  "OK"
end
