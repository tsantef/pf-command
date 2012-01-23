module Commands
  def clone(argv)
    app_id = argv.shift
    directory = argv.shift 

    if app_id.nil? || app_id != app_id.to_i.to_s
      puts "You must specify an app id."
      return false
    end

    phpfog = PHPfog.new
    app = phpfog.get_app(app_id)

    unless app.nil?
      exec("git clone #{app['repo']} #{directory}")
    else
      puts "App #{red(app_id)} not found."
      return false
    end
    true
  end
end

__END__
Clone

Usage: pf clone <app_id> [<directory>]

Description:

  Clones the specified app.

