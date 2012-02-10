require 'nokogiri'
require 'open-uri'

class PHPfog

  $phpfog = nil
  @session = nil

  def initialize
    $phpfog = Rest.new(ENV["PHPFOG_URL"] || "https://www.phpfog.com")
    load_session
  end

  # --- Clouds ----

  def get_dedicated_clouds
    response = api_call do 
      $phpfog.get("/dedicated_clouds", nil, { :accept => "application/json", :content_type => "application/json", "Api-Auth-Token"=>get_session('api-auth-token') })
    end
    return JSON.parse(response.body)
  end

  # --- Apps ----

  def get_apps(cloud_id)
    params = {}
    params = { :cloud_id => cloud_id } unless cloud_id == "0"
    response = api_call do 
      $phpfog.get("/apps", params, { :accept => "application/json", :content_type => "application/json", "Api-Auth-Token"=>get_session('api-auth-token') })
    end
    response_body = JSON.parse(response.body)
    if response.code == 200
      return { :status => response.code, :message => "OK" , :body => response_body }
    else
      return { :status => response.code, :message => response_body["message"] , :body => response_body }
    end
  end

  def get_app(app_id)
    response = api_call do 
      $phpfog.get("/apps/#{app_id}", nil, { :accept => "application/json", :content_type => "application/json", "Api-Auth-Token"=>get_session('api-auth-token') })
    end
    response_body = JSON.parse(response.body)
    p response_body
    if response.code == 200
      return { :status => response.code, :message => "OK" , :body => response_body }
    else
      return { :status => response.code, :message => response_body["message"] , :body => response_body }
    end
  end

  def new_app(cloud_id, jump_start_id, login, mysql_password, domain_name)
    response = api_call do 
      params = { :cloud_id => cloud_id } if cloud_id != "0"
      payload = { 
        "jump_start_id" => jump_start_id, 
        "login" => login,
        "password" => mysql_password,
        "domain_name" => domain_name
      }
      response = $phpfog.post("/apps", params, JSON.generate(payload), { :accept => "application/json", "Api-Auth-Token"=>get_session('api-auth-token') })
    end  
    response_body = JSON.parse(response.body)
    if response.code == 200
      return { :status => response.code, :message => "OK" , :body => response_body }
    else
      return { :status => response.code, :message => response_body["message"] , :body => response_body }
    end
  end

  def delete_app(app_id)
    response = api_call do 
      response = $phpfog.delete("/apps/#{app_id}", nil, { :accept => "application/json", "Api-Auth-Token"=>get_session('api-auth-token') })
    end  
    response
  end

  # --- SSH Keys ----

  def get_sshkeys
    response = api_call do 
      $phpfog.get("/ssh_keys", nil, { :accept => "application/json", :content_type => "application/json", "Api-Auth-Token"=>get_session('api-auth-token') })
    end
    response_body = JSON.parse(response.body)
    if response.code == 200
      return { :status => response.code, :message => "OK" , :body => response_body }
    else
      return { :status => response.code, :message => response_body["message"] , :body => response_body }
    end
  end

  def new_sshkey(ssh_key_name, ssh_key_key)
    response = api_call do 
      payload = { 'name' => ssh_key_name, 'key' => ssh_key_key }
      response = $phpfog.post("/ssh_keys", nil, JSON.generate(payload), { :accept => "application/json", "Api-Auth-Token"=>get_session('api-auth-token') })
    end  
    response
  end
  
  def delete_sshkey(sshkey_id)
    response = api_call do 
      response = $phpfog.delete("/ssh_keys/#{sshkey_id}", nil, { :accept => "application/json", "Api-Auth-Token"=>get_session('api-auth-token') })
    end  
    response
  end

  def get_app_categories
    response = api_call do 
      $phpfog.get("/app_categories", nil, { :accept => "application/json", :content_type => "application/json", "Api-Auth-Token"=>get_session('api-auth-token') })
    end
    return api_expect(response, [200]) do |api_response|
      return { :status => response.code, :message => "OK" , :body => api_response }
    end
  end

  # --- Untility ----

  def domain_available?(domain_name)
    response = api_call do
      params = { :domain_name => domain_name }
      $phpfog.get("/apps/subdomain_available", params, { :accept => "application/json", :content_type => "application/json", "Api-Auth-Token"=>get_session('api-auth-token') })
    end
    if response.code == 200
      return response.body == 'true'
    else
      failure_message api_response['message']
      exit
    end
  end

  def login
    username = (prompt "PHPFog Username: ").strip
    password = (prompt "PHPFog Password: ", true).strip

    payload = { 'login' => username, 'password' => password }
    response = $phpfog.post("/user_session", nil, JSON.generate(payload), { :accept => "application/json" })
    return api_expect(response, [201]) do |api_response|
      set_session('api-auth-token', api_response['api-auth-token'])
      set_session('username', username)
      return true
    end
  end

  def username
    get_session('username')
  end

  def self.logout
    if File.exists? PHPfog.session_path 
      File.delete PHPfog.session_path
      puts bwhite 'Successfully logged out.'
    else
      puts bwhite 'Already logged out.'
    end
  end

  private

  def self.session_path
    File.expand_path("~#{ENV['USER']}/.pf-command-session")
  end

  def set_session(key, value)
    if @session[key].nil? || @session[key] != value
      @session[key] = value.clone
      save_session
    end
  end

  def get_session(key)
    @session[key]
  end

  def load_session
    begin
      session_path = File.expand_path("~#{ENV['USER']}/.pf-command-session")
      session_file = File.open(session_path, 'r')
      session_json = session_file.readlines.to_s
      @session = JSON.parse(session_json)
    rescue
      @session = {}
    end
  end

  def save_session
    session_path = File.expand_path("~#{ENV['USER']}/.pf-command-session")
    session_file = File.new(session_path, "w+")
    session_file.puts(JSON.generate(@session))
    session_file.close
  end

  def api_expect(response, codes)
    begin
      api_response = JSON.parse(response.body)
      if codes.include?(response.code)
        return yield(api_response)
      else
        failure_message api_response['message']
        return false
      end
    rescue JSON::ParserError
      failure_message "Server response is invalid"
      return false
    end
  end

  def api_call
    begin
      response = yield
      if response.code == 401
        if login
          response = yield
          if response.code == 401
            api_error(response)
          end
          return response
        else
          failure_message "Login failed"
          exit
        end
      elsif response.code == 500
        api_error(response)
      end
      response
    rescue Errno::ECONNREFUSED
      failure_message "Server refused connection"
      exit
    end
  end

  def api_error(response)
    begin
      api_response = JSON.parse(response.body)
      failure_message api_response['message'] 
    rescue
      failure_message "Server response is invalid"
    end
    exit
  end

end
