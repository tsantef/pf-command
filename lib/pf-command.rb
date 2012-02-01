require "pf-command/colorize"
require "pf-command/commandline"
require "pf-command/phpfog"
require "pf-command/prompt"
require "pf-command/rest"
require "pf-command/version"
require "pf-command/shell"

def success_message(message)
  puts bwhite message
end

def failure_message(message)
  puts green message
end
