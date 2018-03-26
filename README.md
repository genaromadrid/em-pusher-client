# Em::Pusher::Client

[![Gem Version][rubygems-image]][rubygems-url]
[![Build Status][travis-image]][travis-url]
[![Coverage Status][coverage-image]][coverage-url]

EventMachine client library for Pusher

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'em-pusher-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install em-pusher-client

## Usage

```ruby
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
    end

    conn.disconnect do
      puts 'gone'
      EM.stop_event_loop
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `rake console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/em-pusher-client.


[rubygems-image]: https://badge.fury.io/rb/em-pusher-client.svg
[rubygems-url]: https://badge.fury.io/rb/em-pusher-client
[travis-image]: https://travis-ci.org/genaromadrid/em-pusher-client.svg?branch=master
[travis-url]: https://travis-ci.org/genaromadrid/em-pusher-client
[coverage-image]: https://coveralls.io/repos/github/genaromadrid/em-pusher-client/badge.svg?branch=master
[coverage-url]: https://coveralls.io/github/genaromadrid/em-pusher-client?branch=master
