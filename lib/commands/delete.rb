module Commands
  def delete(argv)
    command = argv.shift
    
    case command
    when "app"
      app_id = argv.shift
      
      phpfog = PHPfog.new
      response = phpfog.delete_app(app_id)
      if response.code == 204
        success_message 'Successfully deleted app.'
      else
        api_response = JSON.parse(response.body)
        failure_message api_response['message']
      end

    when "sshkey"
      sshkey_id = argv.shift

      phpfog = PHPfog.new
      response = phpfog.delete_sshkey(sshkey_id)
      if response.code == 204
        success_message 'Successfully deleted sshkey.'
      else
        api_response = JSON.parse(response.body)
        failure_message api_response['message']
      end
     
    else
      puts "Unknown Command: " + command
      return false
    end
    
    true
  end
end
