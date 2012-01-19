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
    $http = RestClient::Resource.new uri.host, {:user => username, :password => password}
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
    
    args = []
    args << payload unless payload.nil?
    args << params unless params.nil?
    args << { :cookies => $cookies } unless $cookies.nil?
    puts green args.inspect

    begin
      $last_resp = $http[path].send(method, *args).to_s
    rescue RestClient::ExceptionWithResponse => e
      puts e.http_code.to_s + " " + path
      $last_resp = e.response
      puts yellow $last_resp.cookies.inspect
    rescue Errno::ECONNREFUSED
      code = -1
      body = nil
    end

puts bwhite $last_resp.raw_headers.inspect

$cookies = {} if $cookies.nil?
unless $last_resp.raw_headers['set-cookie'].nil?
  $last_resp.raw_headers['set-cookie'].each do |cookie|
    key, value = cookie.split('=')
    $cookies[key] = value
  end
end
    
    puts red $cookies

    $last_resp
  end

end
