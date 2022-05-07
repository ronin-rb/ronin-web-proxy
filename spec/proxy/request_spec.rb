require 'spec_helper'
require 'ronin/web/server/proxy/request'

describe Ronin::Web::Server::Proxy::Request do
  it "must provide the same methods as Ronin::Web::Server::Request" do
    expect(described_class).to be < Ronin::Web::Server::Request
  end

  let(:env) { {} }

  subject { described_class.new(env) }

  describe "#host=" do
    let(:host)     { 'example.com' }
    let(:new_host) { 'evil.com'    }
    let(:env) do
      {'HTTP_HOST' => host}
    end

    before { subject.host = new_host }

    it "must set HTTP_HOST" do
      expect(env['HTTP_HOST']).to eq(new_host)
    end
  end

  describe "#port=" do
    let(:port)     { 80   }
    let(:new_port) { 8080 }
    let(:env) do
      {'SERVER_PORT' => port}
    end

    before { subject.port = new_port }

    it "must set SERVER_PORT" do
      expect(env['SERVER_PORT']).to eq(new_port)
    end
  end

  describe "#scheme=" do
    let(:scheme)     { 'https' }
    let(:new_scheme) { 'http'  }
    let(:env) do
      {'rack.url_scheme' => scheme}
    end

    before { subject.scheme = new_scheme }

    it "must set rack.url_scheme" do
      expect(env['rack.url_scheme']).to eq(new_scheme)
    end
  end

  describe "#ssl=" do
    context "when given true" do
      before { subject.ssl = true }

      it "must set #port to 443" do
        expect(subject.port).to eq(443)
      end

      it "must set #scheme to 'https'" do
        expect(subject.scheme).to eq('https')
      end
    end

    context "when given false" do
      before { subject.ssl = false }

      it "must set #port to 80" do
        expect(subject.port).to eq(80)
      end

      it "must set #scheme to 'http'" do
        expect(subject.scheme).to eq('http')
      end
    end
  end

  describe "#request_method=" do
    let(:request_method)     { 'GET' }
    let(:new_request_method) { 'POST'}
    let(:env) do
      {'REQUEST_METHOD' => request_method}
    end

    before { subject.request_method = new_request_method }

    it "must set REQUEST_METHOD" do
      expect(env['REQUEST_METHOD']).to eq(new_request_method)
    end
  end

  describe "#query_string=" do
    let(:query_string)     { 'GET' }
    let(:new_query_string) { 'POST'}
    let(:env) do
      {'QUERY_STRING' => query_string}
    end

    before { subject.query_string = new_query_string }

    it "must set QUERY_STRING" do
      expect(env['QUERY_STRING']).to eq(new_query_string)
    end
  end

  describe "#xhr=" do
    context "when given true" do
      before { subject.xhr = true }

      it "must set HTTP_X_REQUESTED_WITH to 'XMLHttpRequest'" do
        expect(env['HTTP_X_REQUESTED_WITH']).to eq('XMLHttpRequest')
      end
    end

    context "when given false" do
      let(:env) do
        {'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest'}
      end

      before { subject.xhr = false }

      it "must delete the HTTP_X_REQUESTED_WITH header" do
        expect(env['HTTP_X_REQUESTED_WITH']).to be(nil)
      end
    end
  end

  describe "#content_type=" do
    let(:content_type)     { 'text/html' }
    let(:new_content_type) { 'text/xml'  }
    let(:env) do
      {'CONTENT_TYPE' => content_type}
    end

    before { subject.content_type = new_content_type }

    it "must set CONTENT_TYPE" do
      expect(env['CONTENT_TYPE']).to eq(new_content_type)
    end
  end

  describe "#accept_encoding=" do
    let(:accept_encoding)     { 'gzip' }
    let(:new_accept_encoding) { '*'    }
    let(:env) do
      {'HTTP_ACCEPT_ENCODING' => accept_encoding}
    end

    before { subject.accept_encoding = new_accept_encoding }

    it "must set HTTP_ACCEPT_ENCODING" do
      expect(env['HTTP_ACCEPT_ENCODING']).to eq(new_accept_encoding)
    end
  end

  describe "#user_agent=" do
    let(:user_agent)     { 'FireFox' }
    let(:new_user_agent) { 'Chrome'  }
    let(:env) do
      {'HTTP_USER_AGENT' => user_agent}
    end

    before { subject.user_agent = new_user_agent }

    it "must set HTTP_USER_AGENT" do
      expect(env['HTTP_USER_AGENT']).to eq(new_user_agent)
    end
  end

  describe "#referer=" do
    let(:referer)     { 'http://example.com/' }
    let(:new_referer) { 'http://evil.com/'    }
    let(:env) do
      {'HTTP_REFERER' => referer}
    end

    before { subject.referer = new_referer }

    it "must set HTTP_REFERER" do
      expect(env['HTTP_REFERER']).to eq(new_referer)
    end
  end

  describe "#body=" do
    let(:body)     { '<html><body>test</body></html>'       }
    let(:new_body) { '<html><body>rewritten!</body></html>' }
    let(:env) do
      {'rack.input' => body}
    end

    before { subject.body = new_body }

    it "must set rack.input" do
      expect(env['rack.input']).to eq(new_body)
    end
  end
end
