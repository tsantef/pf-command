module Commands
  def list(argv)
    command = argv.shift

    case command
    when "clouds"
      phpfog = PHPfog.new
      clouds = phpfog.get_dedicated_clouds
      clouds << {"dedicated_cloud"=>{"name"=>"Shared", "id"=>0, "subscription_plan_id"=>1}}
      clouds.each do |cloud|
        puts format_item(cloud['dedicated_cloud']['name'], cloud['dedicated_cloud']['id'])
      end

    when "apps"
      cloud_id = argv.shift
      phpfog = PHPfog.new

      apps = phpfog.get_apps(cloud_id)
      apps.each do |app|
        app_status = app['app']['aasm_state']
        case app_status
        when "Running"
          app_status = green(app_status)
        else
        end
        puts format_item(app['app']['domain_name'], app['app']['id'], app_status)
      end

    when "sshkeys"
      phpfog = PHPfog.new
      sshkeys = phpfog.get_sshkeys  
      sshkeys.each do |sshkey|
        puts format_item(sshkey['ssh_key']['name'], sshkey['ssh_key']['id'])
      end
    else
      puts "Unknown Command: " + (command || '')
      return false
    end

    true
  end

  private 

  def format_item(name, id, description=nil)
    if description.nil?
      "#{bwhite(name)} (ID:#{cyan id})"
    else
      "#{bwhite(name)} - #{description} (ID:#{cyan id})"
    end
  end
end
