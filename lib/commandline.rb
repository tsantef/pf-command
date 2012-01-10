module Commandline
  
  class CommandHelper
    @metadata = []
  end
  
  def run(argv, load_path = nil)
    if argv.nil? || !argv.is_a?(Array) || argv.length < 1
      puts "Invalid Command"
      return false 
    end

    Dir["#{load_path}/*.rb"].each {|file| require file } unless load_path.nil?
    
    command = argv.shift
    
    if command == 'help'
      help_command = argv.shift
      
      show_command_help(help_command)
      
      return true
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
      help_method = "#{method_name}_usage"
      if Commands.respond_to?(help_method) then
        required_method = Commands.method(help_method)
        help_text += required_method.call() + "\n"
      end
    end
    
    help_text
  end
  module_function :help
  
  def self.show_command_help(help_command)
    help_text = ''
      
    help_method = "#{help_command}_help"
    if Commands.respond_to?(help_method) then
      required_method = Commands.method(help_method)
      help_text += required_method.call()
    end
      
    puts help_text
  end
  
end