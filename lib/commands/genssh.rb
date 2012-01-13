module Commands
  def genssh(argv)
    app_id = argv.shift
    
    #return false if app_id.nil?
    
    phpfog = PHPfog.new
    puts "What is your email address?" 
    shell_script = IO.popen(get_script_path("genssh.sh"))   
    ssh_key=nil
    while shell_script.gets do
      ssh_key=$_
      puts $_
    end
    shell_script.close
    if /^ssh-rsa/.match( ssh_key ) 
      phpfog.new_ssh("",ssh_key)
      puts "word"
    end
    true
  end
end
