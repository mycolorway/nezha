require "nezha/version"
require 'active_support/core_ext/hash'
require 'active_support/json'
require 'faraday'
require 'cgi'
require 'openssl'

module Nezha
  class Client
    DEFAULT_ENDPOINT = ENV['NEZHA_ENDPOINT'] || 'https://fk.zhirenhr.com'
    DEFAULT_VERSION = ENV['NEZHA_API_VERSION'] || 'v1'

    attr_reader :endpoint, :access_key, :secret_key, :version

    def initialize(access_key: ENV['FACELESS_VOID_ACCESS_KEY'], secret_key: ENV['FACELESS_VOID_SECRET_KEY'], endpoint: DEFAULT_ENDPOINT, version: DEFAULT_VERSION)
      raise "Invalid Endpoint" if endpoint.nil? || endpoint.empty? || endpoint !~ /^https?:\/\/.+$/ || endpoint.include?('?')

      @access_key = access_key || ""
      @secret_key = secret_key || ""
      @version = version || ""
      @endpoint = endpoint
    end


    def get(path, data={})
      signed_request :get, path, data
    end

    def post(path, data={})
      signed_request :post, path, data
    end

    def patch(path, data={})
      signed_request :patch, path, data
    end

    private

    def sign(method, path, access_key, tonce, payload)
      string_to_sign = "#{method.upcase}#{path}#{access_key}#{tonce}#{payload}"
      OpenSSL::HMAC.hexdigest 'SHA256', secret_key, string_to_sign
    end

    def signed_request(method, path, data)
      raise "Access Key should not be empty" if access_key.nil? || access_key.empty?
      payload = ActiveSupport::JSON.encode data

      params = {}
      params[:payload] = payload
      params[:access_key] = access_key
      params[:tonce] = Time.now.to_i
      params[:signature] = sign(method, full_path(path), params[:access_key], params[:tonce], payload)

      do_request(method, full_path(path), params)
    end

    def do_request(method, path, params)
      conn.send method, path, params
    end

    def conn
      @conn ||= Faraday.new(url: endpoint) do |faraday|
        faraday.request :url_encoded
        faraday.adapter :net_http
      end
    end

    def full_path(path)
      "/api/#{version}#{path}"
    end

  end
end
