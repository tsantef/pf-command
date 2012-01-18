module Commands
  def logout(argv)
    if File.exists? SESSION_PATH 
      File.delete SESSION_PATH
      puts bright 'Successfully logged out.'
    else
      puts bwhite 'Already logged out.'
    end
    true
  end
end
