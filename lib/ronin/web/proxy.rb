#
# ronin-web-proxy - A Man-in-the-Middle (MITM) HTTP proxy server
#
# Copyright (c) 2006-2022 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin-web-proxy.
#
# ronin-web-proxy is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-web-proxy is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-web-proxy.  If not, see <https://www.gnu.org/licenses/>.
#

require 'ronin/web/proxy/request'
require 'ronin/web/proxy/response'
require 'ronin/support/network/http'
require 'ronin/support/cli/printing'

require 'rack/server'
require 'set'

module Ronin
  module Web
    #
    # A Rack application for Man-in-the-Middle (MITM proxying HTTP requests.
    #
    #     require 'ronin/web/proxy'
    #     
    #     log = File.new('log.txt','w+')
    #     
    #     proxy = Ronin::Web::Proxy.new do |proxy|
    #       proxy.on_request do |request|
    #         log.puts "[#{request.ip} -> #{request.host_with_port}] #{request.request_method} #{request.url}"
    #     
    #         request.headers.each do |name,value|
    #           log.puts "#{name}: #{value}"
    #         end
    #     
    #         log.puts request.params.inspect
    #         log.flush
    #       end
    #     
    #       proxy.on_response do |response|
    #         # ...
    #       end
    #     end
    #     
    #     proxy.run!
    #
    # @api public
    #
    class Proxy

      include Ronin::Support::CLI::Printing

      # Default host the Proxy will bind to
      DEFAULT_HOST = '0.0.0.0'

      # Default port the Proxy will listen on
      DEFAULT_PORT = 8080

      # Default server the Proxy will run on
      DEFAULT_SERVER = 'webrick'

      # Blacklisted HTTP response Headers.
      HEADERS_BLACKLIST = Set[
        'Transfer-Encoding'
      ]

      #
      # Creates a new {Proxy} application.
      #
      # @yield [proxy]
      #   If a block is given, it will be passed the new proxy.
      #
      # @yieldparam [Proxy] proxy
      #   The new proxy object.
      #
      def initialize
        @connections = {}

        yield self if block_given?
      end

      #
      # The default host to bind to.
      #
      # @return [String]
      #   The host name.
      #
      def self.host
        @host ||= DEFAULT_HOST
      end

      #
      # Sets the default host.
      #
      # @param [String] new_host
      #   The new host name.
      #
      # @return [String]
      #   The new host name.
      #
      def self.host=(new_host)
        @host = new_host
      end

      #
      # The default port to listen on.
      #
      # @return [Integer]
      #   The default port number.
      #
      def self.port
        @port ||= DEFAULT_PORT
      end

      #
      # Sets the default port to listen on.
      #
      # @param [Integer] new_port
      #   The new port number.
      #
      # @return [Integer]
      #   The new port number.
      #
      def self.port=(new_port)
        @port = new_port
      end

      #
      # Uses the given block to intercept incoming requests.
      #
      # @yield [request]
      #   The given block will receive every incoming request, before it
      #   is proxied.
      #
      # @yieldparam [ProxyRequest] request
      #   A proxied request.
      #
      # @return [Proxy]
      #   The proxy app.
      #
      def on_request(&block)
        @on_request_block = block
        return self
      end

      #
      # Uses the given block to intercept proxied responses.
      #
      # @yield [(request), response]
      #   The given block will receive every proxied response.
      #
      # @yieldparam [Request] request
      #   A proxied request.
      #
      # @yieldparam [Response] response
      #   A proxied response.
      #
      # @return [Proxy]
      #   The proxy app.
      #
      def on_response(&block)
        @on_response_block = block
        return self
      end

      #
      # Runs the proxy as a standalone Web Server.
      #
      # @param [String] host
      #   The host to bind to.
      #
      # @param [Integer] port
      #   The port to listen on.
      #
      # @param [Hash{Symbol => Object}] rack_options
      #   Additional options to pass to [Rack::Server.new](https://rubydoc.info/gems/rack/Rack/Server#initialize-instance_method).
      #
      def run!(host: self.class.host, port: self.class.port, **rack_options)
        rack_options = rack_options.merge(
          app:  self,
          Host: host,
          Port: port
        )

        server = Rack::Server.new(rack_options)

        server.start do |handler|
          trap(:INT)  { quit!(server,handler) }
          trap(:TERM) { quit!(server,handler) }
        end

        return self
      end

      #
      # Stops the proxy.
      #
      # @param [Rack::Server] server
      #   The Rack Handler server.
      #
      # @param [#stop!, #stop] handler
      #   The Rack Handler.
      #
      # @api private
      #
      def quit!(server,handler)
        # Use thins' hard #stop! if available, otherwise just #stop
        handler.respond_to?(:stop!) ? handler.stop! : handler.stop
      end

      #
      # @see #call!
      #
      # @api semipublic
      #
      def call(env)
        dup.call!(env)
      end

      #
      # Receives incoming requests, proxies them, allowing manipulation
      # of the requests and their responses.
      #
      # @param [Hash, Rack::Request] env
      #   The request.
      #
      # @return [Array, Response]
      #   The response.
      #
      # @api private
      #
      def call!(env)
        request = Request.new(env)

        @on_request_block.call(request) if @on_request_block

        print_debug "Proxying #{request.url} for #{request.ip_with_port}"
        request.headers.each do |name,value|
          print_debug "  #{name}: #{value}"
        end

        response = proxy(request)

        if @on_response_block
          case @on_response_block.arity
          when 1 then @on_response_block.call(response)
          else        @on_response_block.call(request,response)
          end
        end

        print_debug "Returning proxied response for #{request.ip_with_port}"
        response.headers.each do |name,value|
          print_debug "  #{name}: #{value}"
        end

        return response
      end

      #
      # Creates a new connection or fetches an existing connection.
      #
      # @param [String] host
      #   The host to connect to.
      #
      # @param [Integer] port
      #   The port to connect to.
      #
      # @param [Boolean] ssl
      #   Indicates whether to use SSL.
      #
      # @return [Ronin::Support::Network::HTTP]
      #   The HTTP connection.
      #
      # @api private
      #
      def connection(host,port, ssl: nil)
        key = [host,port,ssl]

        @connections.fetch(key) do
          @connections[key] = Support::Network::HTTP.new(host,port, ssl: ssl)
        end
      end

      #
      # Proxies a request.
      #
      # @param [ProxyRequest] request
      #   The request to send.
      #
      # @return [Response]
      #   The response from the request.
      #
      # @api private
      #
      def proxy(request)
        host    = request.host
        port    = request.port
        ssl     = request.scheme == 'https'
        method  = request.request_method.downcase.to_sym
        path    = request.path
        query   = request.query_string
        headers = request.headers
        body    = request.body.read

        http = connection(host,port,ssl: ssl)
        http_response = http.request(method,path, query:   query,
                                                  headers: headers,
                                                  body:    body)

        http_headers = {}

        http_response.each_capitalized do |name,value|
          unless HEADERS_BLACKLIST.include?(name)
            http_headers[name] = value
          end
        end

        return Response.new(http_response.body || '',
                            http_response.code,
                            http_headers)
      end

    end
  end
end
