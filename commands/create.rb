module Commands
  def create(argv)
    command = argv.shift
    
    case command
    when "app"
      
      cloud_id = argv.shift
      
      if cloud_id == '1' || cloud_id == 'shared'
        cloud_id = ''
      end 
      
      phpfog = PHPfog.new
      
      mysql_password = prompt 'MySQL Password: '
      if mysql_password.empty? 
        puts 'New app canceled'
        exit
      end
      
      domain_name = nil
      while domain_name == nil
        temp_domain_name = prompt 'Domain Name: '
        
        if temp_domain_name.empty? 
          puts bwhite 'New app canceled'
          exit
        end
        
        if phpfog.domain_available?(temp_domain_name)
          domain_name = temp_domain_name
        else
          puts bwhite 'Domain name not available. Try again.'
        end
      end

      app_id = phpfog.new_app(cloud_id, 16, domain_name, mysql_password)
      if !app_id.nil?
        puts bwhite 'New app created.' + "(ID:#{red app_id})"
      else
        puts bwhite 'New app failed to be created.'
      end
      
    else
      puts "Unknown Command: " + (command || '')
      return false
    end
    
    true
  end
end