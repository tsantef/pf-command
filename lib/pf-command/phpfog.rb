require 'nokogiri'
require 'open-uri'

class PHPfog

  $phpfog = nil
  @session = nil
  $isLoggedIn = false

  def initialize
#    $phpfog = Rest.new("https://www.phpfog.com")
  $phpfog = Rest.new("http://localhost:3000")
    load_session
  end

  def get_dedicated_clouds
    response = api_call do 
      $phpfog.get("/dedicated_clouds", nil, { :accept => "application/json", :content_type => "application/json", "Api-Auth-Token"=>get_session('api-auth-token') })
    end
    return JSON.parse(response.body)
  end

  def get_apps(cloud_id)
    response = api_call do 
      $phpfog.get("/apps", { :cloud_id => cloud_id }, { :accept => "application/json", :content_type => "application/json", "Api-Auth-Token"=>get_session('api-auth-token') })
    end
    return JSON.parse(response.body)
      # authorize!

      # apps_url = nil
      # app_item_selector = nil


      # if cloud_id == '1' || cloud_id == 'shared'
      #   apps_url = '/account'
      #   app_item_selector = '#clouds li:last .drop-down li'
      #   app_link_selector = 'a'
      #   app_status_selector = nil
      # else
      #   apps_url = "/clouds/#{cloud_id}"
      #   app_item_selector = '#apps li.app'
      #   app_link_selector = 'h4 a'
      #   app_status_selector = '.title span'
      # end

      # resp = rpeek $phpfog.get(apps_url)

      # doc = Nokogiri::HTML(resp.body)

      # apps = Array.new
      # app_items = doc.css(app_item_selector)
      # app_items.each do |app_item|
      #   app_link = app_item.at_css(app_link_selector)
      #   app_name = app_link.text.strip
      #   app_href = app_link.attr('href')
      #   app_status = app_item.at_css(app_status_selector).text.strip unless app_status_selector.nil?

      #   appIdRe = /\/(\d+)/
      #   m = appIdRe.match(app_href)
      #   app_id = m.captures.shift unless m.nil?

      #   apps << { 'id' => app_id || 1, 'link' => app_href, 'name' => app_name, 'status' => app_status }
      # end

      # apps
  end

  def get_app(app_id)
    authorize!

    app = {}

    resp = rpeek $phpfog.get("/apps/#{app_id}")

    if resp.code == 200
      doc = Nokogiri::HTML(resp.body)

      app['site_address'] = doc.css("#app-view-live a").attr('href')
      app['repo'] = doc.css("#source_code ul code").text.strip[2..-1].gsub(/^git clone /, "")

      return app
    else
      return nil
    end
  end

  def delete_app(app_id)
    authorize!

    resp = rpeek $phpfog.get("/apps/#{app_id}")
    resp = rpeek $phpfog.delete("/apps/#{app_id}", { 'authenticity_token' => get_auth_token(resp.body) })

    resp.code == 200
  end

  def domain_available?(domain_name)
    authorize!
    resp = rpeek $phpfog.get("/apps/subdomain_available?app[domain_name]=#{domain_name}", nil, { 'Accept' => 'application/json, text/javascript, */*; q=0.01', 'X-Requested-With' => 'XMLHttpRequest', 'Accept-Charset' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.3', 'Accept-Charset' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.3', 'Connection' => 'keep-alive'  })
    return resp.code == '200' && resp.body == 'true'
  end

  def new_app(cloud_id, jumpstart_id, domain_name, mysql_password)
    authorize!

    new_app_path = '/apps/new'

    unless cloud_id.nil? || cloud_id.empty?
      new_app_path += "?cloud_id=#{cloud_id}"
    end

    resp = rpeek $phpfog.get(new_app_path)
    resp = rpeek $phpfog.post("/apps", { 'authenticity_token' => get_auth_token(resp.body),
                                          'cloud_id' => cloud_id,
                                          'app[jump_start_id]' => jumpstart_id,
                                          'app[login]' => 'Custom App',
                                          'app[password]' => mysql_password,
                                          'app[domain_name]' => domain_name })

    if resp.code == 302
      appIdRe = /\/(\d+)/
      m = appIdRe.match(resp['location'])
      return m.captures.shift unless m.nil?
    end
    nil
  end

  def login
    username = (prompt "Username: ").strip
    password = (prompt "Password: ", true).strip

    payload = { 'login' => username, 'password' => password }
    response = $phpfog.post("/user_session", nil, JSON.generate(payload), { :accept => "application/json" }) #"Api-Auth-Token"=>"just junkeee",
    api_responce = JSON.parse(response.body)

    if response.code == 201
      set_session('api-auth-token', api_responce['api-auth-token'])
      set_session('username', username)
      return true
    else
      puts api_responce['message']
      return false
    end

  end

  def username
    get_session('username')
  end

  def get_sshkeys
    response = api_call do 
      $phpfog.get("/ssh_keys", nil, { :accept => "application/json", :content_type => "application/json", "Api-Auth-Token"=>get_session('api-auth-token') })
    end
    return JSON.parse(response.body)
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

  def api_call
    response = yield
    if response.code == 401 && login
      response = yield
      if response.code == 401
        api_response = JSON.parse(response.body)
        puts api_response['message']
        exit
      end
      return response
    elsif response.code == 500
      api_response = JSON.parse(response.body)
      puts api_response['message']
      exit
    end
    response
  end

end
