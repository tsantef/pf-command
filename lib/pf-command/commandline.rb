require 'yaml'

module Commandline
  
  class CommandHelper
    @metadata = []
  end
  
  def run!(argv)
    if argv.nil? || !argv.is_a?(Array) || argv.length < 1
      puts "Invalid Command"
      return false 
    end

    Dir[File.expand_path(File.dirname(__FILE__) + '/../commands') + '/*.rb'].each {|file| require file }
    
    command = argv.shift
    
    if command == 'help' 
      help_command = argv.shift

      unless help_command.nil? || help_command.empty?
        show_command_help(help_command)
        return true
      end
      
      puts "Help expects an argument"
      return false
    end
  
    if Commands.method_defined?(command) then
      c = CommandHelper.new
      c.extend Commands
      required_method = Commands.instance_method(command)
      return required_method.bind(c).call(argv)
    else
      puts "Invalid Command '#{command}'"
      return false
    end  
    
    true
  end
  module_function :run!
end