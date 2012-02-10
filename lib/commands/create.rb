module Commands
  def create(argv)
    command = argv.shift

    case command
    when "app"
      phpfog = PHPfog.new

      cloud_id = argv.shift
      cloud_id = "0" if cloud_id.nil? || cloud_id.downcase == "shared"
      
      api_response = phpfog.get_app_categories
      categories = api_response[:body]

      jump_starts = []

      index = 1
      categories.each do |category|
        puts "#{category['name']}"
        category['jump_starts'].each do |jump_start|
          if !jump_start.nil?
            puts " #{bwhite(index)}. #{jump_start['name']} #{jump_start['version']}"
            category.delete('jump_starts')
            jump_starts << {:jump_start_id => jump_start['id'], :category_id => category['id'], :jump_start_name => jump_start['name'] }
            index += 1
          end
        end
      end
      jump_start_index = prompt 'Choose a jump start (Default Custom App): '
      jump_start_index = jump_start_index.to_i

      jump_start_id = nil
      category_id = nil
      jump_start_name = nil
      if jump_start_index == 0 
        jump_start_id = 16 
        category_id = 2
        jump_start_name = "Custom App"
      else
        jump_start_id = jump_starts[jump_start_index-1][:jump_start_id] 
        category_id = jump_starts[jump_start_index-1][:category_id]  
        jump_start_name = jump_starts[jump_start_index-1][:jump_start_name]  
      end

      puts "You selected #{bwhite(jump_start_name)}"

      username = "Custom App"
      if category_id != 2
        username = prompt "#{jump_start_name} Username: "
        if username.empty?
          puts 'New app canceled'
          exit
        end
      end

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

      api_response = phpfog.new_app(cloud_id, jump_start_id, "Custom App", mysql_password, domain_name)
      if api_response[:status] == 201
        app = api_response[:body]
        app['id']
        puts format_item("New app created", app['id'])
      else
        failure_message(api_response[:message])
      end

    when "sshkey"
      name = argv.shift
      sshkey = argv.shift
      phpfog = PHPfog.new
      api_response = phpfog.new_sshkey(name,sshkey)
      if api_response.code == 201
        success_message 'Successfully create new sshkey.'
      else
        api_response = JSON.parse(response.body)
        failure_message api_response['message']
      end
    else
      puts "Unknown Command: " + (command || '')
      return false
    end

    true
  end
end

__END__
Create

Usage: pf create <app_id>

Description:

  Clones an app to the current directory.

