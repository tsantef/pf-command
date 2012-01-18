module Commands
  def clone(argv)
    app_id = argv.shift

    return false if app_id.nil?

    phpfog = PHPfog.new
    apps = phpfog.get_app(app_id)
      # this could be dangerous
    exec(apps['repo']) 
    true
  end
end

__END__
Clone

Usage: pf clone <app_id>

Description:

  Clones an app to the current directory.

