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

require 'ronin/web/proxy/routing'

module Ronin
  module Web
    module Server
      class Base
        include Proxy::Routing
      end
    end
  end
end
