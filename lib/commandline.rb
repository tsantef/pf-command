module Commandline
  def run(argv, load_path = nil)
    if argv.nil? || !argv.is_a?(Array) || argv.length < 1
      puts "Invalid Command"
      return false 
    end
    
    Dir["#{load_path}/*.rb"].each {|file| require file } unless load_path.nil?
    
    command = argv.shift

    required_module = Kernel.const_get("Commands")
    if required_module.respond_to?(command) then
      required_method = required_module.method(command)
      return required_method.call(argv)
    else
      puts "Invalid Command '#{command}'"
      return false
    end  
    
    true
  end
  module_function :run
end