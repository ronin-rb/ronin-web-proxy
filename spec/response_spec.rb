require 'spec_helper'
require 'ronin/web/proxy/response'

describe Ronin::Web::Proxy::Response do
  it "must provide the same methods as Ronin::Web::Server::Response" do
    expect(described_class).to be < Ronin::Web::Server::Response
  end
end
