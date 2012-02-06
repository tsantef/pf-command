module Commands
  def list(argv)
    command = argv.shift

    case command
    when "clouds"
      phpfog = PHPfog.new
      clouds = phpfog.get_dedicated_clouds
      clouds << {"name"=>"Shared", "id"=>0, "subscription_plan_id"=>1}
      clouds.each do |cloud|
        puts format_item(cloud['name'], cloud['id'])
      end

    when "apps"
      cloud_id = argv.shift
      cloud_id = "0" if cloud_id.nil? || cloud_id.downcase == "shared"
      phpfog = PHPfog.new
      api_response = phpfog.get_apps(cloud_id)
      if api_response[:status] == 200
        apps = api_response[:body]
        if apps.count > 0 
          apps.each do |app|
            app_status = app['status']
            app_status = green(app_status) if app_status == "Running"
            puts format_item(app['name'], app['id'], app_status)
          end
        else
          failure_message("No apps in the specified cloud")
        end
      else
        failure_message(api_response[:message])
      end

    when "sshkeys"
      phpfog = PHPfog.new
      api_response = phpfog.get_sshkeys
      if api_response[:status] == 200
        sshkeys = api_response[:body]
        if sshkeys.count > 0 
          sshkeys.each do |sshkey|
            puts format_item(sshkey['name'], sshkey['id'])
          end
        else
          failure_message("No ssh keys found.")
        end
      else
        failure_message(api_response[:message])
      end
    else
      puts "Unknown Command: " + (command || '')
      return false
    end

    true
  end

  private 

end
