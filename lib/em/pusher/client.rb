# frozen_string_literal: true

require_relative 'client/version'
require_relative 'client/connection'
require_relative 'client/msg_parser'

module EM
  module Pusher
    module Client
      DEFAULT_OPTIONS = {
        app_id: nil,
        app_secret: nil,
        scheme: 'ws',
        port: 80,
        encrypted: 'on',
        protocol: 4,
        version: '4.2',
        client_name: 'em-pusher-client',
      }.freeze

      REQUIRED_OPTIONS = %i[key cluster].freeze

      def self.connect(options)
        uri = url(options)
        Connection.connect(uri).tap do |conn|
          yield conn if block_given?
        end
      end

      def self.sign(secret, socket_id, channel_name)
        digest = OpenSSL::Digest::SHA256.new
        string_to_sign = "#{socket_id}:#{channel_name}"
        OpenSSL::HMAC.hexdigest(digest, secret, string_to_sign)
      end

      def self.build_auth(secret, key, socket_id, channel_name)
        sig = sign(secret, socket_id, channel_name)
        "#{key}:#{sig}"
      end

      def self.url(options)
        opts = DEFAULT_OPTIONS.merge(options)
        REQUIRED_OPTIONS.each { |opt| fail ArgumentError, "option #{opt} is required" unless opts[opt] }
        "#{opts[:scheme]}://ws-#{opts[:cluster]}.pusher.com:#{opts[:port]}/app/#{opts[:key]}" \
          "?protocol=#{opts[:protocol]}" \
          "&client=#{opts[:client_name]}" \
          "&version=#{opts[:version]}"
      end
    end
  end
end
