# frozen_string_literal: true

require 'eventmachine'
require 'uri'
require 'json'
require 'websocket'
require 'openssl'

module EM
  module Pusher
    module Client
      class Connection < EM::Connection
        include EM::Deferrable

        attr_accessor :url
        attr_accessor :protocol_version
        attr_accessor :origin

        def self.connect(uri, opts = {})
          p_uri = URI.parse(uri)
          conn = EM.connect(p_uri.host, p_uri.port || 80, self) do |c|
            c.url = uri
            c.protocol_version = opts[:version]
            c.origin = opts[:origin]
          end
          yield conn if block_given?
          conn
        end

        def post_init
          @handshaked = false
          @frame = ::WebSocket::Frame::Incoming::Client.new
        end

        def connection_completed
          @connect.yield if @connect
          @hs = ::WebSocket::Handshake::Client.new(
            url:     @url,
            origin:  @origin,
            version: @protocol_version,
          )
          send_data(@hs.to_s)
        end

        def stream(&cback)
          @stream = cback
        end

        def connected(&cback)
          @connect = cback
        end

        def disconnect(&cback)
          @disconnect = cback
        end

        def connection_established(&cback)
          @connection_established = cback
        end

        def ping(&cback)
          @ping = cback
        end

        # https://pusher.com/docs/pusher_protocol#subscription-events
        def subscribe(channel, auth = nil, channel_data = nil)
          msg = {
            event: 'pusher:subscribe',
            data: {
              channel: channel,
              auth: auth,
              channel_data: channel_data,
            },
          }
          conn.send_msg(msg)
        end

        def receive_data(data)
          return handle_received_data(data) if @handshaked
          @hs << data
          if @hs.finished?
            @handshaked = true
            succeed
          end

          receive_data(@hs.leftovers) if @hs.leftovers
        end

        def send_msg(data, args = {})
          type = args[:type] || :text
          data = data.to_json if data.is_a?(Hash)
          frame = ::WebSocket::Frame::Outgoing::Client.new(
            data: data,
            type: type,
            version: @hs.version,
          )
          send_data(frame.to_s)
        end

        def unbind
          super
          @disconnect.call if @disconnect
        end

      private

        def handle_received_data(data)
          @frame << data
          while (msg = @frame.next)
            process_data(EM::Pusher::Client::MsgParser.new(msg))
          end
        end

        def process_data(parser)
          if parser.event == 'pusher:connection_established'
            process_connection(parser)
          elsif parser.type == :ping
            process_ping
          elsif parser.type == :close
            process_close
          end
          @stream.call(parser) if @stream
        end

        def process_connection(parser)
          socket_id = JSON.parse(parser.json['data'])['socket_id']
          @connection_established.yield(socket_id) if @connection_established
        end

        def process_ping
          @ping.yield if @ping
          send_msg(event: 'pusher:pong')
        end

        def process_close
          unbind
          close_connection
        end
      end
    end
  end
end
