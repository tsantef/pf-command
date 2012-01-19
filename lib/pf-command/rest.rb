require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'
require 'rest_client'

class Rest

  $http = nil
  $last_resp = nil
  $last_params = nil
  $last_payload = nil

  $useragent = ''

  def initialize(url, username = nil, password = nil)
    uri = URI(url)
    $http = RestClient::Resource.new uri.to_s, {:user => username, :password => password}
  end

  def get(path, params = nil)
    path = "#{path}?" + params.map { |k, v| "#{k}=#{v}" }.join("&") unless params.nil? || params.empty?
    make_request(:get, path)
  end

  def post(path, params, payload=nil)
    make_request(:post, path, params, payload)
  end

  def put(path, params, payload=nil)
    make_request(:put, path, params, payload)
  end

  def delete(path, params, payload=nil)
    make_request(:delete, path, params, payload)
  end

  def cookies
    $cookies
  end
  def cookies=(dough)
    $cookies = dough
  end

private

  def cookie_to_s
    cookiestr = ''
    $cookies.each do |key, value|
       cookiestr += "#{key}=#{value}, "
    end
    cookiestr[0..-2]
  end

  def make_request(method, path, params = nil, payload = nil)

    $last_params = params
    $last_payload = payload

    options = {}
    options[:params] = params unless params.nil?
    options[:cookies] = cookies unless cookies.nil?

    args = [payload, options].compact

    begin
      $last_resp = $http[path].send(method, *args)
    rescue RestClient::ExceptionWithResponse => e
      $last_resp = e.response
    rescue Errno::ECONNREFUSED
      code = -1
      body = nil
    end

    $cookies = {} if $cookies.nil?
    unless $last_resp.raw_headers['set-cookie'].nil?
      $last_resp.raw_headers['set-cookie'].each do |cookie|
        key, value = cookie.split('=')
        $cookies[key] = value
      end
    end

    $last_resp
  end

end
