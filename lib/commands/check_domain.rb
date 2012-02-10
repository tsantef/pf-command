module Commands
  def check_domain(argv)
    domain_name = argv.shift

    phpfog = PHPfog.new

    if phpfog.domain_available?(domain_name)
      puts bwhite 'Domain name available.'
    else
      puts bwhite 'Domain name not available. Try again.'
    end

    true
  end
end