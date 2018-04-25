# frozen_string_literal: true

require './lib/em/pusher/client'

pusher_key = 'pusher_key'
channel = 'private-channel'
pusher_secret = 'pusher_secret'

EM.run do
  opts = {
    key: pusher_key,
    cluster: 'us2',
    port: 80,
    scheme: 'ws',
  }
  EM::Pusher::Client.connect(opts) do |conn|
    conn.connected do
      puts 'connected'
    end

    conn.connection_established do |socket_id|
      puts 'callback'
      auth = EM::Pusher::Client.build_auth(pusher_secret, pusher_key, socket_id, channel)
      msg = {
        event: 'pusher:subscribe',
        data: {
          channel: channel,
          auth: auth,
        },
      }
      conn.send_msg(msg)
    end

    conn.errback do |e|
      puts "Got error: #{e}"
    end

    conn.stream do |msg|
      case msg.event
      when 'pusher:connection_established'
        puts 'Connection Established'
      when 'pusher_internal:subscription_succeeded'
        puts "Subscribed to #{msg.json['channel']}"
      when 'someevent'
        puts "#{msg.type}: #{msg.event} >> #{msg.data}"
      else
        puts "unexpected event (#{msg.type}): <#{msg}>"
      end
      # conn.close_connection if closed?
    end

    conn.disconnect do
      puts 'gone'
      EM.stop_event_loop
    end
  end
end
