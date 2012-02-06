module Commands
  def clone(argv)
    app_id = argv.shift
    directory = argv.shift 

    if app_id.nil? || app_id != app_id.to_i.to_s
      failure_message "You must specify an app id."
      return false
    end

    phpfog = PHPfog.new
    api_response = phpfog.get_app(app_id)
    if api_response[:status] == 200
      app = api_response[:body]

      exec("git clone #{app['git_url']} #{directory}")
    else
      failure_message(api_response[:message])
    end

    true
  end
end

__END__
Clone

Usage: pf clone <app_id> [<directory>]

Description:

  Clones the specified app.

