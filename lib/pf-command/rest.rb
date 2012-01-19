require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'
require 'rest-client'

class Rest

  $http = nil
  $cookies = {}
  $last_resp = nil
  $last_params = nil
  $last_payload = nil

  $useragent = ''

  class RestResponce
    attr_accessor :code, :body
  end

  def initialize(url, user = nil, password = nil)
    uri = URI(url)
    $http = RestClient::Resource.new uri.host, {:user => username, :password => password}
  end

  def get(path, params={})
    path = "#{path}?" + params.map { |k, v| "#{k}=#{v}" }.join("&") unless params.empty?
    request(:get, path, params)
  end

  def post(path, params, payload=nil)
    request(:post, path, params, payload)
  end

  def put(path, params, payload=nil)
    request(:put, path, params, payload)
  end

  def delete(path, params, payload=nil)
    request(:delete, path, params, payload)
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

  def make_request(method, params = nil, payload = nil)
    $last_params = params
    $last_payload = payload

    begin
      body, code = $http[path].send(method, args).to_s
    rescue RestClient::ExceptionWithResponse => fail
      code = fail.http_code
      body = fail.http_body
    rescue Errno::ECONNREFUSED
      code = -1
      body = nil
    end

    unless $last_resp['set-cookie'].nil?
      $last_resp['set-cookie'].split(', ').each do |cookie|
        key, value = cookie.split('=')
        $cookies[key] = value
      end
    end

    $last_resp
  end

end
