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

require 'ronin/web/proxy'

module Ronin
  module Web
    class Proxy
      #
      # Adds additional routing class methods for [Sinatra] apps.
      #
      # [Sinatra]: http://sinatrarb.com/
      #
      # ## Example
      #
      #     require 'ronin/web/proxy/mixin'
      #     
      #     include Ronin::Web::Proxy::Mixin
      #     
      #     proxy '/signin' do |proxy|
      #       proxy.on_response do |response|
      #         response.body.gsub!(/https/,'http')
      #       end
      #     end
      #
      # @api semipublic
      #
      module Mixin
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          #
          # Proxies requests to a given path.
          #
          # @param [String] path
          #   The path to proxy requests for.
          #
          # @param [Hash{Symbol => Object}] conditions
          #   Additional routing conditions.
          #
          # @yield [proxy]
          #   The block will be passed the new proxy instance.
          #
          # @yieldparam [Proxy] proxy
          #   The new proxy to configure.
          #
          # @example
          #   proxy '/signin' do |proxy|
          #     proxy.on_response do |response|
          #       response.body.gsub!(/https/,'http')
          #     end
          #   end
          #
          # @see Proxy
          #
          # @api public
          #
          def proxy(path='*',conditions={},&block)
            proxy = Proxy.new(&block)
            route = ->{ proxy.call(env) }

            get(path,conditions,&route)
            post(path,conditions,&route)
            put(path,conditions,&route)
            patch(path,conditions,&route)
            delete(path,conditions,&route)
            options(path,conditions,&route)
          end
        end
      end
    end
  end
end
