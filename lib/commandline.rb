require 'yaml'

module Commandline
  
  class CommandHelper
    @metadata = []
  end
  
  def run(argv)
    if argv.nil? || !argv.is_a?(Array) || argv.length < 1
      puts "Invalid Command"
      return false 
    end

    Dir["#{COMMAND_PATH}/*.rb"].each {|file| require file }
    
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
  module_function :run
  
  def help
    help_text = ''
    
    # usage
    Commands.instance_methods().each do |method_name|
      command_yml_path = "#{COMMAND_PATH}/#{method_name}.yml"
      if File.exists? command_yml_path
        command_info = YAML.load(IO.read(command_yml_path))
        help_text += "   #{command_info['usage']}\n" unless command_info['usage'].nil?
      end
    end
    
    help_text
  end
  module_function :help
  
  def self.show_command_help(method_name)
    help_text = ''
      
    command_json_path = "#{COMMAND_PATH}/#{method_name}.yml"
    if File.exists? command_json_path
      command_json_file = File.open(command_json_path, 'r')
      command_json = command_json_file.readlines.to_s
      command_info = JSON.parse(command_json)
      
      help_text += "   #{command_info['help']}\n" unless command_info['help'].nil?
    end
      
    help_text
  end
  
end