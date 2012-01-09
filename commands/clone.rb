module Commands
  def self.clone(argv)
    app_id = argv.shift
    
    phpfog = PHPfog.new
    apps = phpfog.get_app(app_id)
      # this could be dangerous
    exec(apps['repo']) 
    true
  end
end