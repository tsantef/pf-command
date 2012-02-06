module Commands
  def open(argv)
    command = argv.shift

    case command
    when "app"
      app_id = argv.shift
      phpfog = PHPfog.new
      api_response = phpfog.get_app(app_id)
      if api_response[:status] == 200
        app = api_response[:body]
        system("open", "http://"+app['domain_name'])
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