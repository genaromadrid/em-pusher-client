# frozen_string_literal: true

module EM
  module Pusher
    module Client
      class MsgParser
        attr_reader :json,
                    :data

        def initialize(msg)
          parse(msg)
        end

        def event
          @event ||= json['event']
        end

        def to_s
          @msg.to_s
        end

      private

        def parse(msg)
          @msg = msg
          @json = JSON.parse(msg.data)
          @data =
            if json['data'].is_a?(String)
              JSON.parse(json['data'])
            else
              json['data']
            end
        rescue JSON::ParserError => e
          puts e.message
          # logger.error("Error parsing msg #{e}")
        end
      end
    end
  end
end
