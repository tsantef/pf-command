module Commands
  def delete(argv)
    command = argv.shift
    
    case command
    when "app"
      app_id = argv.shift
      
      phpfog = PHPfog.new
      apps = phpfog.app_delete(app_id)
    else
      puts "Unknown Command: " + command
      return false
    end
    
    true
  end
end
