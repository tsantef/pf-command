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

    command = argv.shift || ''
    command = command.gsub("-","_")

    if command == 'help'
      help_command = argv.shift

      unless help_command.nil? || help_command.empty?
        command_file = File.expand_path(File.dirname(__FILE__) + "/../commands/#{help_command}.rb")
        if File.exists?(command_file)
          file_contents = File.read(command_file)
          if /__END__/.match(file_contents)
            puts File.read(command_file).split('__END__').last
            return true
          else
            puts "No extented help exists for #{bwhite(help_command)} yet."
            return false
          end
        end
        puts "Invalid Command '#{help_command}'"
        return false
      end

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
