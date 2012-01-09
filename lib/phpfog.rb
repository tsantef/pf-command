require 'nokogiri'
require 'open-uri'

class PHPfog
  
  SESSION_PATH = 'session.json'
  
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
    
    resp = rpeek $phpfog.get("/clouds/#{cloud_id}")
    
    doc = Nokogiri::HTML(resp.body)

    apps = Array.new
    app_items = doc.css("#apps li.app")
    app_items.each do |app_item|
      app_link = app_item.at_css("h4 a")
      app_name = app_link.text.strip
      app_href = app_link.attr('href')
      app_status = app_item.at_css(".title span").text.strip

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
    puts red resp.code
    resp = rpeek $phpfog.delete("/apps/#{app_id}", { 'authenticity_token' => get_auth_token(resp.body) })
    puts resp.code
    resp.code == "200"
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
      $isLoggedIn = true
    else
      puts red "Login Failed."
    end

    resp = rpeek $phpfog.get("/account")
    resp.code == "200"
  end
  
  def authorize!
    unless loggedin? || login() 
      throw(:halt, "Not logged in")
    end
  end
  
  private
  
  def rpeek(resp)
    # look for cookie change
    if $session['cookies'].nil? || $phpfog.cookies.to_s != $session['cookies'].to_s
      $session['cookies'] = $phpfog.cookies.clone
      save_session
    end
    resp
  end

  def prompt(msg, isPassword = false)
      print(msg)
      system "stty -echo" if isPassword
      input = gets
      if isPassword 
        system "stty echo"
        puts ''
      end
      input
  end
  
  def load_session
    begin
      session_file = File.open(SESSION_PATH, 'r')
      session_json = session_file.readlines.to_s
      $session = JSON.parse(session_json)
    rescue
      $session = {}
    end
  end
  
  def save_session
    session_file = File.new(SESSION_PATH, "w+")
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