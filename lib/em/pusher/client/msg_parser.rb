# frozen_string_literal: true

module EM
  module Pusher
    module Client
      class MsgParser
        def initialize(msg)
          @msg = msg
        end

        def event
          return '{}' unless json
          @event ||= json['event']
        end

        def to_s
          @msg.to_s
        end

        def type
          @msg.type
        end

        def json
          @json ||= JSON.parse(@msg.data)
        rescue JSON::ParserError
          {}
        end

        def data
          @data =
            if json['data'].is_a?(String)
              JSON.parse(json['data'])
            else
              json['data']
            end
        rescue JSON::ParserError
          {}
        end
      end
    end
  end
end
