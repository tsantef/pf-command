module Commands
  def view(argv)
    command = argv.shift

    case command
    when "app"
      app_id = argv.shift
      phpfog = PHPfog.new
      api_response = phpfog.get_app(app_id)
      if api_response[:status] == 200
        app = api_response[:body]

        app_status = app['status']
        app_status = green(app_status) if app_status == "Running"

        puts "Name: #{bwhite(app['name'])}"
        puts "Id: #{cyan(app['id'])}"
        puts "Url: #{bwhite(app['domain_name'])}"
        puts "Status: #{bwhite(app_status)}"
        puts "Git Url: #{bwhite(app['git_url'])}"
      else
        failure_message(api_response[:message])
      end

    else
      puts "Unknown Command: " + command
      return false
    end

    true
  end
end