# ronin-web-proxy

[![CI](https://github.com/ronin-rb/ronin-web-proxy/actions/workflows/ruby.yml/badge.svg)](https://github.com/ronin-rb/ronin-web-proxy/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/ronin-rb/ronin-web-proxy.svg)](https://codeclimate.com/github/ronin-rb/ronin-web-proxy)

* [Website](https://ronin-rb.dev/)
* [Source](https://github.com/ronin-rb/ronin-web-proxy)
* [Issues](https://github.com/ronin-rb/ronin-web-proxy/issues)
* [Documentation](https://ronin-rb.dev/docs/ronin-web-proxy/frames)
* [Slack](https://ronin-rb.slack.com) |
  [Discord](https://discord.gg/6WAb3PsVX9) |
  [Twitter](https://twitter.com/ronin_rb)

## Description

ronin-web-proxy is a [Rack] based Man-in-the-Middle (MITM) HTTP proxy server
capable of rewriting requests and responses as they pass through.

## Features

* Allows rewriting HTTP requests and responses.
* [Rack] compatible.

## Examples

Start a basic logging project:

```ruby
require 'ronin/web/proxy'

log = File.new('log.txt','w+')

proxy = Ronin::Web::Proxy.new do |proxy|
  proxy.on_request do |request|
    log.puts "[#{request.ip} -> #{request.host_with_port}] #{request.request_method} #{request.url}"

    request.headers.each do |name,value|
      log.puts "#{name}: #{value}"
    end

    log.puts request.params.inspect
    log.flush
  end
end

proxy.run!
```

Using `Ronin::Web::Proxy` with `Ronin::Web::Server`:

```ruby
require 'ronin/web/server'

class App < Ronin::Web::Server::Base

  proxy '/sigin' do |proxy|
    proxy.on_request do |reqquest|
      # ...
    end

    proxy.on_response do |response|
      # ...
    end
  end

end

App.run!
```

## Requirements

* [Ruby] >= 3.0.0
* [ronin-web-server] ~> 0.1

## Install

```shell
$ gem install ronin-web-proxy
```

### Gemfile

```ruby
gem 'ronin-web-proxy', '~> 0.1'
```

### gemspec

```ruby
gem.add_dependency 'ronin-web-proxy', '~> 0.1'
```

## Development

1. [Fork It!](https://github.com/ronin-rb/ronin-web-proxy/fork)
2. Clone It!
3. `cd ronin-web-proxy/`
4. `bundle install`
5. `git checkout -b my_feature`
6. Code It!
7. `bundle exec rake spec`
8. `git push origin my_feature`

## License

ronin-web-proxy - A Man-in-the-Middle (MITM) HTTP proxy server

Copyright (c) 2006-2022 Hal Brodigan (postmodern.mod3 at gmail.com)

This file is part of ronin-web-proxy.

ronin-web-proxy is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ronin-web-proxy is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with ronin-web-proxy.  If not, see <https://www.gnu.org/licenses/>.

[Ruby]: https://www.ruby-lang.org
[Rack]: https://github.com/rack/rack#readme
[ronin-web-server]: https://github.com/ronin-rb/ronin-web-server#readme
