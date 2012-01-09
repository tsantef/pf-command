module Commands
  def self.view(argv)
    command = argv.shift

    phpfog = PHPfog.new
    case command
    when "app"
      app_id = argv.shift
      apps = phpfog.get_app(app_id)
      system("open", apps["site_address"])
    else
      puts "Unknown Command: " + command
      return false
    end

    true
  end
end