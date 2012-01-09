require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'

class Rest

  $user = nil
  $password = nil
  $http = nil
  $cookies = {}
  $last_resp = nil
  $last_params = nil

  $useragent = ''

  def initialize(url, user = nil, password = nil)
    $user = user
    $password = password
    
    uri = URI(url)
    $http = Net::HTTP.new(uri.host, uri.port)
    
    if uri.scheme == 'https'
      $http.use_ssl = true
      $http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    else
      $http.use_ssl = false
    end
  end

  def get(url, params = nil)
    req = Net::HTTP::Get.new(url, { 'Cookie' => cookie_to_s, 'User-Agent' => $useragent })
    make_request(req, params)
  end
  
  def post(url, params, payload = nil)
    req = Net::HTTP::Post.new(url, { 'Cookie' => cookie_to_s, 'User-Agent' => $useragent })
    make_request(req, params, payload)
  end
  
  def put(url, params, payload = nil)
    req = Net::HTTP::Put.new(url, { 'Cookie' => cookie_to_s, 'User-Agent' => $useragent })
    make_request(req, params, payload)
  end
  
  def delete(url, params = nil, payload = nil)
    req = Net::HTTP::Delete.new(url, { 'Cookie' => cookie_to_s, 'User-Agent' => $useragent })
    make_request(req, params, payload)
  end
  
  def cookies
    $cookies
  end 
  def cookies=(dough)
    $cookies = dough
  end
  
  def inspect
    puts "#{bwhite(resp.code)} - #{$last_resp.message}" 
    puts $last_params.inspect
    puts "Cookies: " + $cookies.inspect
    puts $last_resp.body
  end
  
private

  def cookie_to_s
    cookiestr = ''
    $cookies.each do |key, value|
       cookiestr += "#{key}=#{value}, "
    end
    cookiestr[0..-2]
  end
  
  def make_request(req, params = nil, payload = nil)
    $last_params = params
    req.basic_auth($user, $password) unless $user.nil?
    req.set_form_data(params, ';') unless params.nil?

    unless payload.nil?
     req.body = payload
     req.set_content_type('multipart/form-data')
    end
    
    $last_resp = $http.request(req)
    
    unless $last_resp['set-cookie'].nil?
      $last_resp['set-cookie'].split(', ').each do |cookie|
        key, value = cookie.split('=')
        $cookies[key] = value
      end
    end

    $last_resp
  end
  
end
