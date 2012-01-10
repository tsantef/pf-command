module Commands
  def self.list_usage
    "   list clouds\n   list apps {cloud id}" 
  end
  def list(argv)
    command = argv.shift
    
    case command
    when "clouds"
     
      phpfog = PHPfog.new
      clouds = phpfog.get_clouds
      clouds.each do |cloud|
        puts "#{bwhite(cloud['name'])} - #{cloud['description']} (ID:#{red cloud['id']})"
      end
      
    when "apps"
      
      cloud_id = argv.shift
      
      phpfog = PHPfog.new

      apps = phpfog.get_apps(cloud_id)
      apps.each do |app|
        app_status = app['status']
        case app['status']
        when "Running"
          app_status = green(app_status)
        end
        puts "#{bwhite(app['name'])} - #{app_status} (ID:#{red app['id']})"
      end
      
    else
      puts "Unknown Command: " + (command || '')
      return false
    end
    
    true
  end
end