#
# Copyright (c) 2012 NITLab, University of Thessaly, CERTH, Greece
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Syntax: ruby nitosAPI.rb 
#
# == modular architecture
#
# This is an XMLRPC API for the NITOS Scheduler
# NITOS API v2
#

require 'xmlrpc/server'
require 'mysql'
require 'rubygems'
require 'dbi'
require 'time'
require 'date'
require_relative 'scheduler'

counter = 1
file = File.new("../api_conf","r")
while(line = file.gets)
	if(counter == 1)
		$db = line
	elsif(counter == 2)
		$user = line
	elsif(counter == 3)
		$pass = line
	elsif(counter == 4)
		$server = line
	end
	counter = counter + 1
end
file.close

$server = $server[0...-1]
$user = $user[0...-1]
$db = $db[0...-1]
$pass = $pass[0...-1]

puts "Your database: #{$db}"
puts "and your server: #{$server}"

puts "Setting up the XML-RPC server..."
s  = XMLRPC::Server.new(8085, "#{$server}")
s.add_handler("scheduler.server", Scheduler.new)
s.serve

