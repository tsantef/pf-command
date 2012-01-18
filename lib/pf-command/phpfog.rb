require 'nokogiri'
require 'open-uri'

class PHPfog

  $phpfog = nil
  $session = nil
  $isLoggedIn = false

  def initialize
    $phpfog = Rest.new("https://www.phpfog.com")

    load_session
    $phpfog.cookies = $session['cookies'].clone unless $session['cookies'].nil?
  end

  def get_clouds
    authorize!

    resp = rpeek $phpfog.get("/account")

    doc = Nokogiri::HTML(resp.body)

    clouds = Array.new
    cloud_items = doc.css("li.cloud")
    cloud_items.each do |cloud_item|
      cloud_link = cloud_item.at_css("h4 a")
      cloud_name = !cloud_link.nil? ? cloud_link.text.strip : 'Shared Cloud'
      cloud_href = !cloud_link.nil? ? cloud_link.attr('href') : ''
      cloud_desc = cloud_item.at_css(".title p").text.strip

      cloudIdRe = /\/(\d+)/
      m = cloudIdRe.match(cloud_href)
      cloud_id = m.captures.shift unless m.nil?

      clouds << { 'id' => cloud_id || 1, 'link' => cloud_href, 'name' => cloud_name, 'description' => cloud_desc }
    end

    clouds
  end

  def get_apps(cloud_id)
    authorize!

    apps_url = nil
    app_item_selector = nil


    if cloud_id == '1' || cloud_id == 'shared'
      apps_url = '/account'
      app_item_selector = '#clouds li:last .drop-down li'
      app_link_selector = 'a'
      app_status_selector = nil
    else
      apps_url = "/clouds/#{cloud_id}"
      app_item_selector = '#apps li.app'
      app_link_selector = 'h4 a'
      app_status_selector = '.title span'
    end

    resp = rpeek $phpfog.get(apps_url)

    doc = Nokogiri::HTML(resp.body)

    apps = Array.new
    app_items = doc.css(app_item_selector)
    app_items.each do |app_item|
      app_link = app_item.at_css(app_link_selector)
      app_name = app_link.text.strip
      app_href = app_link.attr('href')
      app_status = app_item.at_css(app_status_selector).text.strip unless app_status_selector.nil?

      appIdRe = /\/(\d+)/
      m = appIdRe.match(app_href)
      app_id = m.captures.shift unless m.nil?

      apps << { 'id' => app_id || 1, 'link' => app_href, 'name' => app_name, 'status' => app_status }
    end

    apps
  end

  def get_app(app_id)
    authorize!

    app = {}

    resp = rpeek $phpfog.get("/apps/#{app_id}")
    doc = Nokogiri::HTML(resp.body)

    app['site_address'] = doc.css("#app-view-live a").attr('href')
    app['repo'] = doc.css("#source_code ul code").text.strip[2..-1]

    app
  end

  def app_delete(app_id)
    authorize!

    resp = rpeek $phpfog.get("/apps/#{app_id}")
    resp = rpeek $phpfog.delete("/apps/#{app_id}", { 'authenticity_token' => get_auth_token(resp.body) })

    resp.code == "200"
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

    if resp.code == "302"
      appIdRe = /\/(\d+)/
      m = appIdRe.match(resp['location'])
      return m.captures.shift unless m.nil?
    end
    nil
  end

  def loggedin?
    if $isLoggedIn == false
      rpeek $phpfog.get("/login") # required to establish session
      resp = rpeek $phpfog.get("/account")
      $isLoggedIn = resp.code == "200"
    end
    $isLoggedIn
  end

  def login()
    username = (prompt "Username: ").strip
    password = (prompt "Password: ", true).strip

    # open session
    resp = rpeek $phpfog.get("/login")
    resp = rpeek $phpfog.post("/user_session",
                    { 'authenticity_token' => get_auth_token(resp.body),
                      'user_session[login]' => username,
                      'user_session[password]' => password,
                      'user_session[remember_me]' => '0',
                      'commit' => 'login' })

    if resp.code == '302'
      puts cyan "Login Successfull."
      $session['username'] = username
      $isLoggedIn = true
    else
      puts red "Login Failed."
    end

    resp = rpeek $phpfog.get("/account")
    resp.code == "200"
  end

  def username
    $session['username']
  end

  def authorize!
    unless loggedin? || login()
      throw(:halt, "Not logged in")
    end
  end

  def new_ssh(ssh_key_name, ssh_key_key)
    authorize!

    resp = rpeek $phpfog.get("/account")
    resp = rpeek $phpfog.post("/ssh_keys", { 'authenticity_token' => get_auth_token(resp.body),
                                          'ssh_key[name]' => ssh_key_name,
                                          'ssh_key[key]' => ssh_key_key}
                                         )
    if resp.code == "302"
      idRe = /\/(\d+)/
      m = idRe.match(resp['location'])
      return true
    end
    false
  end
  
  def self.logout
    if File.exists? PHPfog.session_path 
      File.delete PHPfog.session_path
      puts bright 'Successfully logged out.'
    else
      puts bwhite 'Already logged out.'
    end
  end
  
  private

  def self.session_path
    File.expand_path("~#{ENV['USER']}/.pf-command-session")
    
  end

  def rpeek(resp)
    # look for cookie change
    if $session['cookies'].nil? || $phpfog.cookies.to_s != $session['cookies'].to_s
      $session['cookies'] = $phpfog.cookies.clone
      save_session
    end
    resp
  end

  def load_session
    begin
      session_path = File.expand_path("~#{ENV['USER']}/.pf-command-session")
      session_file = File.open(session_path, 'r')
      session_json = session_file.readlines.to_s
      $session = JSON.parse(session_json)
    rescue
      $session = {}
    end
  end

  def save_session
    session_path = File.expand_path("~#{ENV['USER']}/.pf-command-session")
    session_file = File.new(session_path, "w+")
    session_file.puts(JSON.generate($session))
    session_file.close
  end

  def get_auth_token(html)
    #<input name="authenticity_token" type="hidden" value="CSldCthWb3MLTncXJOWiZQOa0R94c0hnnP9ijCM6Dy4=" />
    authTokenRe = /authenticity_token" type="hidden" value="(.*?)"/
    m = authTokenRe.match(html)
    if !m.nil?
      m.captures.shift
    else
      ''
    end
  end

end
