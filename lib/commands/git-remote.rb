module Commands
  def remote(argv)
    app_id = argv.shift

    if app_id.nil? || app_id != app_id.to_i.to_s
      puts "You must specify an app id."
      return false
    end

    phpfog = PHPfog.new
    app = phpfog.get_app(app_id)

    unless app.nil?
      puts bwhite "Adding Remote..."
      abort unless system("git remote add --track master origin #{app['repo']}")
      
      puts bwhite "Adding added untracked changes..."
      abort unless system("git add .")
      
      puts bwhite "Commiting..."
      abort unless systempbb("git commit -m 'added remote'")

      puts "Successfully added remote!"
    else
      puts "App #{red(app_id)} not found."
      return false
    end
    true
  end
end