module Commands
  def whoami(argv)
    phpfog = PHPfog.new

    if phpfog.username.nil?
      puts "Currently Not logged in."
    else
      puts "You are logged in as #{bwhite(phpfog.username)}"
    end
    true
  end
end
