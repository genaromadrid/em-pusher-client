# frozen_string_literal: true

require './lib/em/pusher/client'

EM.run do
  opts = {
    key: 'my-key',
    cluster: 'us2',
    port: 80,
    scheme: 'ws',
  }
  EM::Pusher::Client.connect(opts) do |conn|
    conn.connected do
      puts 'connected'
    end

    conn.callback do
      puts 'callback'
      msg = {
        event: 'pusher:subscribe',
        data: {
          channel: 'my-channel',
        },
      }
      conn.send_msg(msg)
    end

    conn.errback do |e|
      puts "Got error: #{e}"
    end

    conn.stream do |msg|
      puts "stream: <#{msg}>"
      case msg.event
      when 'pusher:connection_established'
        puts 'Connection Established'
      when 'pusher_internal:subscription_succeeded'
        puts "Subscribed to #{msg.json['channel']}"
      when 'someevent'
        puts "someevent: #{msg.data}"
      end
      # conn.close_connection if closed?
    end

    conn.disconnect do
      puts 'gone'
      EM.stop_event_loop
    end
  end
end
