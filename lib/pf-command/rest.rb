require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'
require 'rest_client'

class Rest

  attr_accessor :last_response

  $http = nil

  $last_params = nil
  $last_payload = nil

  $useragent = ''

  def initialize(url, username = nil, password = nil)
    uri = URI(url)

    host = nil
    if uri.user.nil? && uri.password.nil?
      host = uri.to_s
    else
      username = (!uri.user.nil? || uri.user == "") ? CGI::unescape(uri.user) : username
      password = (!uri.password.nil? || uri.password == "") ? CGI::unescape(uri.password) : password
      if uri.port.nil?
        host = "#{uri.scheme}://#{uri.host}"
      else
        host = "#{uri.scheme}://#{uri.host}:#{uri.port}"
      end
    end

    $http = RestClient::Resource.new host, {:user => username, :password => password}
  end

  def get(path, params=nil, headers=nil)
    path = "#{path}?" + params.map { |k, v| "#{k}=#{v}" }.join("&") unless params.nil? || params.empty?
    make_request(:get, path, nil, nil, headers)
  end

  def post(path, params, payload=nil, headers=nil)
    make_request(:post, path, params, payload, headers)
  end

  def put(path, params, payload=nil, headers=nil)
    make_request(:put, path, params, payload, headers)
  end

  def delete(path, params, headers=nil)
    make_request(:delete, path, params, nil, headers)
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

  def make_request(method, path, params=nil, payload=nil, headers=nil)

    $last_params = params
    $last_payload = payload

    options = headers || {}
    options[:params] = params unless params.nil?
    options[:cookies] = cookies unless cookies.nil?

    args = [payload, options].compact

    begin
      last_response = $http[path].send(method, *args)
    rescue RestClient::ExceptionWithResponse => e
      last_response = e.response
    end

    if !last_response.nil?
      $cookies = {} if $cookies.nil?
      unless last_response.raw_headers['set-cookie'].nil?
        last_response.raw_headers['set-cookie'].each do |cookie|
          key, value = cookie.split('=')
          $cookies[key] = value
        end
      end
    end

    last_response
  end

end
