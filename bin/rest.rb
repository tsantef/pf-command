#!/usr/bin/env ruby

lib = File.expand_path(File.dirname(__FILE__) + '/../lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)

require 'rubygems'
require 'pf-command'
require 'json'


r = Rest.new("http://localhost:9999")

payload = "PAYLOADq" # {"test"=>"1"}.to_json
params = {"paramm"=>'222'}
cookies = {"_phpfog.com_session"=>"69a8c467f43a10bef4dc0c5255b5ab44"}

r.cookies = cookies

puts r.post("/test", params, payload)

