#!/usr/bin/env ruby

require 'bundler/setup'
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
