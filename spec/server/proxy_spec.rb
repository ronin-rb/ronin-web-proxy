require 'spec_helper'
require 'ronin/web/server/proxy'

describe 'ronin/web/server/proxy' do
  it { expect(Ronin::Web::Server::Base).to include(Ronin::Web::Proxy::Mixin) }
end
