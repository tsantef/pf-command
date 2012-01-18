module Commands
  def logout(argv)
    PHPfog.logout
    return true
  end
end