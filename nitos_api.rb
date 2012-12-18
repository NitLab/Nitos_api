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
# Syntax: ruby nitos_api.rb 
#
# ==Description
#
# This is an XMLRPC API for the NITOS Scheduler
# Please edit api_conf file, according to your configuration.
# NITOS API  v1.2
#

require "mysql"
require "rubygems"
require "dbi"
require "xmlrpc/server"
require "time"
require "date"

class Scheduler

	counter = 1
	file = File.new("api_conf","r")
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

#	$server = ARGV[0]
#	$db = ARGV[1]
#	$user = ARGV[2]
#	$pass = ARGV[3]
	puts "Your database: #{$db}"
	puts "and your server: #{$server}"

##################################################################
# GET methods
##################################################################			
# The available get methods:
# getNodes, getChannels, getTestbedInfo, getReservedNodes,
# getSlices, getUsers
##################################################################

##################################################################
# Returns the table node_list.
#
# Returns a struct for each node with all the information we have about it.Inside this struct 
# there is another struct for the 3D position of the node.
# [{hostname="",node_id="",node_type="",floor="",view="",wall="",position:{X="",Y="",Z=""}},
#	 {hostname="",...																														}] 
##################################################################

	def getNodes(filter, retValue)
		l = retValue.size
		f_l = filter.length
		i=z=0
		fin = nil
		final_result = Array.new
		puts "Connecting to database..."
		# connect to the MySQL server
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
 
		if retValue.empty? && filter.empty? 
			my_query = dbh.prepare("SELECT name, id, type, floor, view, wall, x, y, z FROM node_list")
			my_query.execute()	
			final = Struct.new(:hostname,:node_id,:node_type,:floor,:view,:wall,:position)
pos = Struct.new(:X,:Y,:Z)
			pos_result = Array.new
			i=0
			my_query.fetch do | n |
				pos_result[i] = pos.new("#{n[6]}","#{n[7]}","#{n[8]}")
				final_result[i] = final.new("#{n[0]}","#{n[1]}","#{n[2]}","#{n[3]}","#{n[4]}","#{n[5]}",pos_result[i])
				puts final_result[i]
				i=i+1
			end 
		elsif !retValue.empty? && filter.empty?
			my_query = Array.new
			temp = Array.new
			retValue.each { |value|
							# name parsing because of different names in our database
							if (value == "hostname")
									my_query[i] = dbh.prepare("SELECT name  FROM node_list ORDER BY name")
							elsif (value == "node_id")
									my_query[i] = dbh.prepare("SELECT id  FROM node_list ORDER BY name")
							elsif (value == "node_type")
									my_query[i] = dbh.prepare("SELECT type  FROM node_list ORDER BY name")
							elsif (value == "position")
									my_query[i] = dbh.prepare("SELECT X, Y, Z  FROM node_list ORDER BY name")
							elsif (value == "floor")
									my_query[i] = dbh.prepare("SELECT floor  FROM node_list ORDER BY name")
							elsif (value == "view")
									my_query[i] = dbh.prepare("SELECT view  FROM node_list ORDER BY name")
							elsif (value == "wall")
									my_query[i] = dbh.prepare("SELECT wall  FROM node_list ORDER BY name")
							else
									puts "Not valid filter"
									return "Please give a valid filter"
#									my_query[i] = dbh.prepare("SELECT #{value} FROM node_list ORDER BY name")
							end
							temp = my_query[i].execute()
							i=i+1
			}
			my_query[0].each do | n |
				final = Struct.new(fin, *retValue.each).new()
				pos = Struct.new(:X,:Y,:Z)
				if (retValue[0] == "position")
						final[0] = pos.new("#{n[0]}","#{n[1]}","#{n[2]}")
						final_result[z] = final
						z=z+1
				else
						final[0] = n[0]
						final_result[z] = final
						z=z+1
				end
			end
			if l!=1
				x=1
				while x < l do
	if (retValue[x] == "position")
						j=0
						my_query[x].each do | n |
						puts n
							final_result[j][x] = pos.new("#{n[0]}","#{n[1]}","#{n[2]}")
							j=j+1
		        end
					else
						j = 0
						my_query[x].each do | n |
							final_result[j][x]=n[0]
							j=j+1
						end
					end
					x = x + 1	
				end
			end
	elsif retValue.empty? && !filter.empty?
			my_query = Array.new

			# name parsing because of different names in our database
			filter.each { |fkey, fvalue|
							if (fkey == "hostname")
									my_query[i] = dbh.prepare("SELECT name, id, type, floor, view, wall, x, y, z FROM node_list WHERE name = '#{fvalue}'")
							elsif (fkey == "node_id")
									my_query[i] = dbh.prepare("SELECT name, id, type, floor, view, wall, x, y, z FROM node_list WHERE id = '#{fvalue}'")
							elsif (fkey == "node_type")
									my_query[i] = dbh.prepare("SELECT name, id, type, floor, view, wall, x, y, z FROM node_list WHERE type = '#{fvalue}'")
							elsif (fkey == "position")
								fvalue.each { | fkey2, fvalue2|
# Needs improvement!!!
									my_query[i] = dbh.prepare("SELECT name, id, type, floor, view, wall, x, y, z FROM node_list WHERE #{fkey2} = '#{fvalue2}'")
								}
							elsif (["floor", "view", "wall"].include?(fkey))
								my_query[i] = dbh.prepare("SELECT name, id, type, floor, view, wall, x, y, z FROM node_list WHERE #{fkey} = '#{fvalue}'")
							else
									puts "Not valid filter"
									return "Please give a valid filter"
							end	
							my_query[i].execute()
			        i=i+1
			}
			final = Struct.new(:hostname,:node_id,:node_type,:floor,:view,:wall,:position)
			pos = Struct.new(:X,:Y,:Z)
			pos_result = Array.new
			i=j=0
			my_query[j].fetch do | n |
				pos_result[i] = pos.new("#{n[6]}","#{n[7]}","#{n[8]}")
				final_result[i] = final.new("#{n[0]}","#{n[1]}","#{n[2]}","#{n[3]}","#{n[4]}","#{n[5]}",pos_result[i])
#				puts final_result[i]
				i=i+1
				j=j+1
		end
		elsif !retValue.empty? && !filter.empty? 
			query = "SELECT "
			retValue.each { | value |
				if value == "position"
					query << "X, Y, Z, "
				elsif value == "node_id"
					query << "id, "
				elsif value == "node_type"
					query << "type, "
				elsif value == "hostname"
					query << "name, "
				elsif ["floor", "view", "wall"].include?(value)
					query << "#{value}, "
				else
					puts "Not valid retValue"
					return "Please give valid retValue"
				end
			}
			query = query[0..-3]
			query << " FROM node_list WHERE "
			filter.each { | fkey, fvalue |
				if fkey == "position"
# Needs improvement!!!
					fvalue.each{ | n |			
						query << "X = '#{n[0]}' AND Y = '#{n[1]}' AND Z = '#{n[2]}' "
					}
				elsif fkey == "node_id"
					query << "id = '#{fvalue}' AND "
				elsif fkey == "node_type"
					query << "type = '#{fvalue}' AND "
				elsif fkey == "hostname"
					query << "name = '#{fvalue}' AND "
				elsif ["floor", "view", "wall"].include?(fkey)
					query << "#{fkey} = '#{fvalue}' AND "
				else
					puts "Not valid filter"
					return "Please give valid filter"
				end
			}
			query = query[0..-5]
			query << "ORDER BY name"
			puts query
			my_query = dbh.prepare(query)
			my_query.execute()
			i=0
#			while x < l
			my_query.fetch do | n |
				x = j = 0
				puts n
				pos = Struct.new(:X,:Y,:Z)
				final = Struct.new(fin, *retValue.each).new()
				while x < l
					if (retValue[x] == "position")
							final[x] = pos.new("#{n[j]}","#{n[j+1]}","#{n[j+2]}")
							j = j + 3
							puts final[x]
							x += 1
					else
						final[x] = n[j]
						puts final[x]
						x += 1
						j += 1
					end
					final_result[i] = final	
					puts final_result[i]
					i += 1
				end
			end	
		end
		return final_result
	end

###################################################################
# Returns the table spectrum.
#
# Returns a struct for each channel with all the information we have about it.
# [{channel_id="",modulation="",channel="",frequency=""},
#	 {channel_id="",...		 														 	}] 
###################################################################
	def getChannels(filter, retValue)
		l = retValue.size
		f_l = filter.length
		i=z=0
		fin = nil
		final_result = Array.new
		"Connecting to database..."
		# connect to the MySQL server
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")

		if retValue.empty? && filter.empty? 
			my_query = dbh.prepare("SELECT id, modulation, channel, frequency FROM spectrum")
			my_query.execute()				
			final = Struct.new(:channel_id,:modulation,:channel,:frequency)
			i=0
			my_query.fetch do | n |
				final_result[i] = final.new("#{n[0]}","#{n[1]}","#{n[2]}","#{n[3]}")
				i=i+1
			end
		elsif !retValue.empty? && filter.empty?
			my_query = Array.new
			retValue.each { |value|
				my_query[i] = dbh.prepare("SELECT #{value}  FROM spectrum ORDER BY channel")
				my_query[i].execute()	
				i=i+1
			}
			my_query[0].each do | n |
				final = Struct.new(fin, *retValue.each).new()
				final[0] = n[0]
				final_result[z] = final
				z=z+1
			end
			if l!=1
				x=1
				while x < l do
					j = 0
					my_query[x].each do | n |
						final_result[j][x]=n[0]
						j=j+1
					end
					x = x + 1	
				end
			end
		elsif retValue.empty? && !filter.empty?
			my_query = Array.new	
			filter.each { |fkey, fvalue|
				my_query[i] = dbh.prepare("SELECT id, modulation, channel, frequency FROM spectrum WHERE #{fkey} = '#{fvalue}'")
				my_query[i].execute()
			        i=i+1
			}
			final = Struct.new(:channel_id,:modulation,:channel,:frequency)
			i=j=0
			my_query[j].fetch do | n |
				final_result[i] = final.new("#{n[0]}","#{n[1]}","#{n[2]}","#{n[3]}")
				i=i+1
				j=j+1
			end
		elsif !retValue.empty? && !filter.empty? 
			my_query = Array.new
			retValue.each { |value|
				filter.each { |fkey, fvalue|
					my_query[i] = dbh.prepare("SELECT #{value}  FROM spectrum WHERE #{fkey} = '#{fvalue}' ORDER BY channel")
					my_query[i].execute()	
					i=i+1
				}
			}
			my_query[0].each do | n |
				final = Struct.new(fin, *retValue.each).new()
				final[0] = n[0]
				final_result[z] = final
				z=z+1
			end
			if l!=1
				x=1
				while x < l do
					j = 0
					my_query[x].each do | n |
						final_result[j][x]=n[0]
						j=j+1
					end
					x = x + 1	
				end
			end 
		end						
		puts "#{final_result}"
		return final_result
	end

###################################################################
# Returns the table slices.
#
# Returns a struct for each slice with all the information we have about it.
# [{slice_id="",slice_name="",user_id=[[""],[""]]},
#	 {slice_id="",...		 														 	}] 
###################################################################
	def getSlices(filter, retValue)
		l = retValue.size
		f_l = filter.length
		i=z=0
		fin = nil
		final_result = Array.new
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
#		if retValue.empty? && filter.empty? 
			final = Struct.new(:slice_id,:slice_name,:user_ids)
			my_query = dbh.prepare("SELECT id, slice_name FROM slices")
			my_query.execute()				
			i=0
			my_query.fetch do | n |
				# get users for this slice
				my_query = dbh.prepare("SELECT jos_users.id FROM jos_users, users_slices WHERE jos_users.id=users_slices.user_id AND users_slices.slice_id='#{n[0]}'")
				my_query.execute()

				tmp = Array.new
				j = 0
				my_query.fetch do | k |
#puts "#{k[0]}"
					tmp[j] = "#{k[0]}"
					j=j+1
				end
				final_result[i] = final.new("#{n[0]}","#{n[1]}", tmp)
				i=i+1
			end  
			puts "#{final_result}"
			final_result
	end

###################################################################
# Returns the table reservation.
#
# Returns a struct for each reserved node.
# [{reservation_id="",slice_id="",start_time="",end_time="",node_id=""},
#	 {reservation_id="",...		 														 							}] 
###################################################################
	def getReservedNodes(filter, retValue)
		l = retValue.size
		f_l = filter.length
		i=z=0
		fin = nil
		final_result = Array.new
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		# get the time now
		time = Time.new
		now = time.strftime("%Y-%m-%d %H:%M:%S") 
#		if retValue.empty? && filter.empty? 
			final = Struct.new(:reservation_id,:slice_id,:start_time,:end_time,:node_id)
			# select only the active reservations. Those that have not expired
			my_query = dbh.prepare("SELECT id, username, unix_timestamp(begin_time), unix_timestamp(end_time), node_id FROM reservation WHERE end_time>'#{now}'")
#my_query = dbh.prepare("SELECT id, username, unix_timestamp(begin_time), unix_timestamp(end_time), node_id FROM reservation WHERE begin_time>='20120801'")
			my_query.execute()				
			i=0
			my_query.fetch do | n |
				# get users for this slice
				my_query = dbh.prepare("SELECT id FROM slices WHERE slice_name='#{n[1]}'")
				my_query.execute()
				my_query.fetch do | k |
					final_result[i] = final.new("#{n[0]}","#{k[0]}","#{n[2]}", "#{n[3]}", "#{n[4]}")
				end
				i=i+1
			end  			
			puts "#{final_result}"
			final_result
	end

###################################################################
# Returns the table spec_reserve.
#
# Returns a struct for each reserved channel.
# [{reservation_id="",slice_id="",start_time="",end_time="",channel_id=""},
#	 {reservation_id="",...		 														 									}] 
###################################################################
	def getReservedChannels()
			final = Struct.new(:reservation_id,:slice_id,:start_time,:end_time,:channel_id)
			final_result = Array.new			
			# connect to the MySQL server
			puts "Connecting to database..."
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get the time now
			time = Time.new
			now = time.strftime("%Y-%m-%d %H:%M:%S")
			final = Struct.new(:reservation_id,:slice_id,:start_time,:end_time,:channel_id)
			# select only the active reservations. Those that have not expired...
			my_query = dbh.prepare("SELECT id, username, unix_timestamp(begin_time), unix_timestamp(end_time), spectrum_id FROM spec_reserve WHERE end_time>'#{now}'")
#my_query = dbh.prepare("SELECT id, username, unix_timestamp(begin_time), unix_timestamp(end_time), node_id FROM reservation WHERE end_time>='#{now}'")
			my_query.execute()
			i=0
			my_query.fetch do | n |
					# get users for this slice
					my_query = dbh.prepare("SELECT id FROM slices WHERE slice_name='#{n[1]}'")
					my_query.execute()
					my_query.fetch do | k |
#	puts "#{k[0]}"
							final_result[i] = final.new("#{n[0]}","#{k[0]}","#{n[2]}", "#{n[3]}", "#{n[4]}")
					end
				i=i+1
			end  
			puts "#{final_result}"
			final_result
	end

###################################################################
# Returns the table jos_users and the rsa_keys.
#
# Returns a struct for each user and all the information we have about him.
# [{user_id="",username="",email="",keys=[[""],[""]]},
#	 {user_id="",...		 															}] 
###################################################################
	def getUsers()
			final = Struct.new(:user_id,:username,:email,:keys)
			final_result = Array.new
			# connect to the MySQL server
			puts "Connecting to database..."
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			my_query = dbh.prepare("SELECT id, username, email FROM jos_users WHERE block='0' AND id!='62'")
			my_query.execute()				
			i=0
			my_query.fetch do | n |
					# get users for this slice
					my_query = dbh.prepare("SELECT rsa_keys.key FROM rsa_keys WHERE user_id='#{n[0]}'")
					my_query.execute()
					tmp = Array.new
					j=0
					my_query.fetch do | k |
#puts "#{k[0]}"
							tmp[j] = "#{k[0]}"
							j=j+1
					end

					final_result[i] = final.new("#{n[0]}","#{n[1]}", "#{n[2]}", tmp)
					i=i+1
			end  
			puts "#{final_result}"
			final_result
	end

###################################################################			
# Returns information about the testbed
###################################################################
	def getTestbedInfo()
			final = Struct.new(:name,:grain,:OMF_version,:scheduler_version,:gw_address,:longitude,:latitude)
			final_result = final.new("nitos","1800","5.3","1.0","nitlab.inf.uth.gr","39.360839","22.949989")			
			puts "result: #{final_result}"
			final_result
	end

##################################################################
# ADD methods
###################################################################
# Available ADD methods:
# reserveNodes, reserveChannels, addUser, addUserToSlice,
# addUserKey, addSlice, addNode, addChannel


#####################################################################
# Returns the node's id
#####################################################################

	def reserveNodes(nodesInfo)
		already_reserved = Array.new
		final_reserved = Array.new
		slice_name = Array.new
		nodes = Array.new
		slice_id = 0
		time1 = 0
		time2 = 0
		nodesInfo.each_pair { | name, value |
				if(name == "slice_id")
								slice_id = value
				elsif(name == "start_time")
								time1 = value.to_i
				elsif(name == "end_time")
								time2 = value.to_i
				elsif(name == "nodes")
								nodes = value
				else
								puts "wrong parameter: #{name}"
								return "wrong parameter: #{name}"
				end				
		}
		puts slice_id
		puts nodes
		puts time1
		puts time2
		time1 = Time.at(time1).to_datetime
		time2 = Time.at(time2).to_datetime
		# check if the time slot is correct
		if (time1.min != 0 && time1.min != 30 && time1.sec !=0)||(time2.min != 0 && time2.min != 30 && time2.sec !=0)
			puts "False time value. Minutes and seconds must be 00 or 30"
			return -1
		end	
		if (time2.hour-time1.hour > 4)
			puts "False time period. The period should be 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 hours"
			return -1
		end
		if (time2.hour - time1.hour == 4)
				if(time2.min != 0 && time2.min != 0)
					puts "False time period. The period should be 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 hours"
					return -1
				end
		end
		start_time = time1.strftime("%Y-%m-%d %H:%M:%S")
		finish_time = time2.strftime("%Y-%m-%d %H:%M:%S")
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		my_query = dbh.prepare("SELECT node_id FROM reservation WHERE begin_time <= '#{start_time}' AND end_time > '#{start_time}'")
		my_query.execute()
		i = 0
		my_query.fetch do | n |
			nodes.each do | id |
				if n[0].to_f == id.to_f
					already_reserved[i] = id
					i += 1
				end	
			end
		end
#final_reserved = nodesInfo.values[1] - already_reserved
final_reserved = nodes - already_reserved
		# find the slice_name
		my_query = dbh.prepare("SELECT slice_name FROM slices WHERE id = '#{slice_id}'")
		result = my_query.execute()
		my_query.fetch do | name |
			slice_name = name
		end
		puts slice_name
		# insert values into the database
		i = 0
		final_reserved.each do | id |
#dbh.do("INSERT INTO reservation (username, begin_time,#{nodesInfo.keys[2]},#{nodesInfo.keys[3]}) VALUES ('#{slice_name[0]}','#{nodesInfo.values[1]}','#{nodesInfo.values[2]}','#{id}')")i
			puts id
			id = id.to_i
			puts id
			dbh.do("INSERT INTO reservation (username,begin_time,end_time,node_id) VALUES ('#{slice_name[0]}','#{start_time}','#{finish_time}','#{id}')")
			final_reserved[i] = id
			i += 1
		end
		return final_reserved
	end

#####################################################################
# Returns the channel's id
#####################################################################

	def reserveChannels(channelInfo)
		already_reserved = Array.new
		final_reserved = Array.new
		slice_name = Array.new
		channels = Array.new
		slice_id = 0
		time1 = 0
		time2 = 0
		channelInfo.each_pair { | name, value |
				if(name == "slice_id")
								slice_id = value
				elsif(name == "start_time")
								time1 = value.to_i
				elsif(name == "end_time")
								time2 = value.to_i
				elsif(name == "channels")
								channels = value
				else
								puts "wrong parameter: #{name}"
								return "wrong parameter: #{name}"
				end				
		}
		puts slice_id
		puts channels
		puts time1
		puts time2
		time1 = Time.at(time1).to_datetime
		time2 = Time.at(time2).to_datetime
		# check if the time slot is correct
		if (time1.min != 0 && time1.min != 30 && time1.sec !=0)||(time2.min != 0 && time2.min != 30 && time2.sec !=0)
			puts "Faulse time value. Minutes and seconds must be 00 or 30"
			return -1
		end	
		if (time2.hour-time1.hour > 4)
			puts "Faulse time period. The period should be 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 hours"
			return -1
		end
		if (time2.hour - time1.hour == 4)
				if(time2.min != 0 && time2.min != 0)
					puts "Faulse time period. The period should be 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 hours"
					return -1
				end
		end
		start_time = time1.strftime("%Y-%m-%d %H:%M:%S")
		finish_time = time2.strftime("%Y-%m-%d %H:%M:%S")
		puts start_time
		puts finish_time
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		my_query = dbh.prepare("SELECT spectrum_id FROM spec_reserve WHERE begin_time <= '#{start_time}' AND end_time > '#{start_time}'")
		my_query.execute()
		i = 0
		my_query.fetch do | n |
			channels.each do | id |
				if n[0].to_f == id.to_f
					already_reserved[i] = id
					i += 1
				end	
			end
		end
		final_reserved = channels - already_reserved
	my_query = dbh.prepare("SELECT slice_name FROM slices WHERE id = '#{slice_id}'")
		result = my_query.execute()
		my_query.fetch do | name |
			slice_name = name
		end
		puts slice_name
		i = 0
		final_reserved.each do | id |
#dbh.do("INSERT INTO spec_reserve (#{channelInfo.keys[0]}, #{channelInfo.keys[1]},#{channelInfo.keys[2]},#{channelInfo.keys[3]}) VALUES ('#{channelInfo.values[0]}','#{channelInfo.values[1]}','#{channelInfo.values[2]}','#{id}')")
			dbh.do("INSERT INTO spec_reserve (username,begin_time,end_time,spectrum_id) VALUES ('#{slice_name[0]}','#{start_time}','#{finish_time}','#{id}')")
				final_reserved[i] = id
				i += 1
		end
		return final_reserved
	end

##################################################################
# Adds a new user into jos_users table
# Returns the new id of the user
##################################################################
	def addUser(userInfo)
		new_id = nil
		username = 0
		email = 0
		userInfo.each_pair { | name, value |
				if(name == "username")
								username = value
				elsif(name == "email")
								email = value
				else
								puts "wrong parameter: #{name}"
								return "wrong parameter: #{name}"
				end				
		}
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		dbh.do("INSERT INTO jos_users (username) VALUES ('#{username}')")
		id = dbh.prepare("SELECT id FROM jos_users WHERE username = '#{username}'")
		id.execute()
		id.fetch do | n |
			new_id = n[0]
		end
			my_query = dbh.prepare("UPDATE jos_users SET email = '#{email}' WHERE id = '#{new_id}'")
			my_query.execute()
		return new_id
	end

##################################################################
# Adds a new user to an existing slice
# Returns 0 for success or -1 for failure
##################################################################
	def addUserToSlice(userToSliceInfo)
		num = 0
		new_id = 0
		user_id = 0
		slice_id = 0
		userToSliceInfo.each_pair { | name, value |
				if(name == "user_id")
								user_id = value
				elsif(name == "slice_id")
								slice_id = value
				else
								puts "wrong parameter: #{name}"
								return "wrong parameter: #{name}"
				end				
		}
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		dbh.do("INSERT INTO users_slices (user_id) VALUES ('#{user_id}')")
		id = dbh.prepare("SELECT id FROM users_slices WHERE user_id = '#{user_id}'")
		id.execute()
		id.fetch do | n |
			new_id = n[0]
		end
			num = dbh.do("UPDATE users_slices SET slice_id = '#{slice_id}' WHERE id = '#{new_id}'")
		if (num == 0)	
				return -1
		end
		return 0
	end

###################################################################
# Adds a new user's key to rsa_keys table
# Returns 0 for success or -1 for failure
##################################################################
	def addUserKey(userKeyInfo)
		num = 0
		user_id = 0
		new_id = 0
		key = 0
		slice_id = 0
		userKeyInfo.each_pair { | name, value |
				if(name == "user_id")
								user_id = value
				elsif(name == "key")
								key = value
				elsif(name == "slice_id")
								slice_id = value

				else
								puts "wrong parameter: #{name}"
								return "wrong parameter: #{name}"
				end				
		}
		puts "Connecting to database..."
		# connect to the MySQL server
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		dbh.do("INSERT INTO rsa_keys (user_id) VALUES ('#{user_id}')")
		id = dbh.prepare("SELECT id FROM rsa_keys WHERE user_id = '#{user_id}'")
		id.execute()
		id.fetch do | n |
			new_id = n[0]
		end
### WE NEED TO ASSOCIATE THE KEY WITH THE RIGHT SLICE. NOW WE CONSIDER THAT THE USER IS ASSOCIATED WITH ONE SLICE ###
#	sliceId = dbh.prepare("SELECT slice_id FROM users_slices WHERE user_id = '#{user_id}'")
#		sliceId.execute()
#		sliceId.fetch do |sid|
#			puts sid.class
#			puts key.class
#			puts new_id
#			num = dbh.do("UPDATE rsa_keys SET slice_id = '#{sid[0]}', rsa_keys.key = '#{key}' WHERE id = '#{new_id}'")
			num = dbh.do("UPDATE rsa_keys SET slice_id = '#{slice_id}', rsa_keys.key = '#{key}' WHERE id = '#{new_id}'")
#		end
		if (num == 0)	
				return -1
		end
		return 0
	end

#################################################################
# Adds a new slice into slices table
# Returns the new id of the slice
##################################################################
	def addSlice(sliceInfo)
		new_id = nil
		slice_name = nil
		sliceInfo.each_pair { |name, value |
			if(name == "slice_name")
				slice_name = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end		
		}
		puts "Connecting to database..."
		# connect to the MySQL server
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		dbh.do("INSERT INTO slices (slice_name) VALUES ('#{slice_name}')")
		id = dbh.prepare("SELECT id FROM slices WHERE slice_name = '#{slice_name}'")
		id.execute()
		id.fetch do | n |
			new_id = n[0]
		end
		return new_id			
	end

#################################################################
# Adds a new node into node_list table
# Returns the new id of the node
##################################################################
	def addNode(nodeInfo)
		new_id = nil
		hostname = 0
		node_type = 0
		floor = 0
		view = 0
		wall = 0
		position = Struct.new(:X,:Y,:Z)
		nodeInfo.each_pair { | name, value |
			if(name == "hostname")
				hostname = value
			elsif(name == "type")
				node_type = value
			elsif(name == "floor")
				floor = value
			elsif(name == "view")
				view = value
			elsif(name == "wall")
				wall = value
			elsif(name == "position")
				position = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		dbh.do("INSERT INTO node_list (name,type,floor,view,wall,X,Y,Z) VALUES ('#{hostname}','#{node_type}','#{floor}','#{view}','#{wall}','#{position.values[0]}','#{position.values[1]}','#{position.values[2]}')")
		id = dbh.prepare("SELECT id FROM node_list WHERE name = '#{hostname}'")
		id.execute()
		id.fetch do | n |
			new_id = n[0]
		end	
		return new_id
	end

#################################################################
# Adds a new channel into spectrum table
# Returns the new id of the channel
##################################################################
	def addChannel(channelInfo)			
		new_id = nil
		channel = 0
		frequency = 0
		modulation = 0	
		channelInfo.each_pair { | name, value |
			if(name == "channel")
				channel = value
			elsif(name == "frequency")
				frequency = value
			elsif(name == "modulation")
				modulation = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		dbh.do("INSERT INTO spectrum (channel) VALUES ('#{channel}')")
		id = dbh.prepare("SELECT id FROM spectrum WHERE channel = '#{channel}'")
		id.execute()
		id.fetch do | n |
			new_id = n[0]
		end
		num = dbh.do("UPDATE spectrum SET frequency = '#{frequency}', modulation = '#{modulation}' WHERE id = '#{new_id}'")
		return new_id
	end

##################################################################
# DELETE methods
###################################################################
# Available DELETE methods:
# deleteKey, deleteNode, deleteUser, deleteUserFromSlice,
# deleteSlice, deleteChannel, releaseNodes, releaseChannels
	
###################################################################
# Delete a key from rsa_keys table
# Returns 0 for success or -1 for failure
##################################################################
	def deleteKey(keyInfo)
		num = 0
		key = nil
		keyInfo.each_pair { | name, value |
			if(name == "key")
				key = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		num = dbh.do("DELETE FROM rsa_keys WHERE rsa_keys.key = '#{key}'")
		if (num == 1)	
				return 0
		end
		return -1
	end

###################################################################
# Delete a node from node_list table
# Returns 0 for success or -1 for failure
##################################################################
	def deleteNode(nodeInfo)
		num = 0
		node_id = nil
		nodeInfo.each_pair { | name, value |
			if(name == "node_id")
				node_id = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		num = dbh.do("DELETE FROM node_list WHERE id = '#{node_id}'")
		if (num == 1)	
				return 0
		end
		return -1
	end

###################################################################
# Delete a user from jos_users table
# Returns 0 for success or -1 for failure
##################################################################
	def deleteUser(userInfo)
		num = 0
		user_id = nil
		userInfo.each_pair { | name, value |
			if(name == "user_id")
				user_id = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		num = dbh.do("DELETE FROM jos_users WHERE id = '#{user_id}' AND id!='62'")
		if (num == 1)	
				return 0
		end
		return -1
	end

###################################################################
# Delete a user from slice in user_slices table
# Returns 0 for success or -1 for failure
##################################################################
	def deleteUserFromSlice(userSliceInfo)
		num = 0
		user_id = nil
		slice_id = nil
		userSliceInfo.each_pair { | name, value |
			if(name == "user_id")
				user_id = value
			elsif(name == "slice_id")
				slice_id = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		num = dbh.do("DELETE FROM users_slices WHERE user_id = '#{user_id}' AND slice_id = '#{slice_id}'")
		if (num == 1)	
				return 0
		end
		return -1
	end

###################################################################
# Delete a slice from slices table
# Returns 0 for success or -1 for failure
##################################################################
	def deleteSlice(sliceInfo)
		num = 0
		slice_id = nil
		sliceInfo.each_pair { | name, value |
			if(name == "slice_id")
				slice_id = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		num = dbh.do("DELETE FROM slices WHERE id = '#{slice_id}'")
		if (num == 1)	
				return 0
		end
		return -1
	end

###################################################################
# Delete a channel from spectrum table
# Returns 0 for success or -1 for failure
##################################################################
	def deleteChannel(channelInfo)
		num = 0
		channel_id = nil
		channelInfo.each_pair { | name, value |
			if(name == "channel_id")
				channel_id = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		num = dbh.do("DELETE FROM spectrum WHERE id = '#{channel_id}'")
		if (num == 1)	
				return 0
		end
		return -1
	end

###################################################################
# Releases a number of nodes that belong in a reservation
# Returns the reservation's id
###################################################################
	def releaseNodes(reservation)
		deleted = Array.new
		ids = Array.new
		reservation.each_pair { | name, value |
			if(name == "reservation_ids")
				ids = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		ids.each do | id |
			num = dbh.do("DELETE FROM reservation WHERE id = '#{id}'")
			if num == 1
				deleted.push(id)
			end
		end
		return deleted 
	end

###################################################################
# Releases a number of channels that belong in a reservation
# Returns the reservation's id
###################################################################
	def releaseChannels(reservation)
		deleted = Array.new
		ids = Array.new
		reservation.each_pair { | name, value |
			if(name == "reservation_ids")
				ids = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		ids.each do | id |
			num = dbh.do("DELETE FROM spec_reserve WHERE id = '#{id}'")
			if num == 1
				deleted.push(id)
			end
		end
		return deleted
	end

##################################################################
# UPDATE methods
###################################################################
# Available Update methods: 
# updateNode, updateChannel, updateUser, updateSlice, 
# updateReservedNodes, updateReservedChannels
###################################################################

###################################################################
# Updates a node from node_list table 
# Returns 0 for success or -1 for failure
###################################################################
	def updateNode(nodeInfo)
		num = Array.new
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		node_id = dbh.prepare("SELECT id FROM node_list WHERE id = '#{nodeInfo.values[0]}'")
		node_id.execute()
		node_id.fetch do | id |
			nodeInfo.values[1].each do | key, value |
					num.push(dbh.do("UPDATE node_list SET #{key} = '#{value}' WHERE id = '#{id[0]}'"))
			end	
		end		
		num.each do | i |
			if (num[i] == 1)	
					return 0
			end
		end
		return -1
	end

###################################################################
# Updates a channel from spectrum table 
# Returns 0 for success or -1 for failure
###################################################################
	def updateChannel(channelInfo)
		num = Array.new
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		channel_id = dbh.prepare("SELECT id FROM spectrum WHERE id = '#{channelInfo.values[0]}'")
		channel_id.execute()
		channel_id.fetch do | id |
			channelInfo.values[1].each do | key, value |
				num.push(dbh.do("UPDATE spectrum SET #{key} = '#{value}' WHERE id = '#{id[0]}'"))
			end	
		end
		# if one field of the table was updated, its enough
		num.each do | i |
			if (num[i] == 1)	
					return 0
			end
		end
		return -1
	end

###################################################################
# Updates a user from jos_users table 
# Returns 0 for success or -1 for failure
###################################################################
	def updateUser(userInfo)
		num = Array.new
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		user_id = dbh.prepare("SELECT id FROM jos_users WHERE id = '#{userInfo.values[0]}'")
		user_id.execute()
		user_id.fetch do | id |
			userInfo.values[1].each do | key, value |
				num.push(dbh.do("UPDATE jos_users SET #{key} = '#{value}' WHERE id = '#{id[0]}'"))
			end	
		end
		# if one field of the table was updated, its enough
		puts num	
		if(num[0] == 1)
				return 0
		end
		num.each do | i |
			if (num[i] == 1)	
					return 0
			end
		end
		return -1
	end

###################################################################
# Updates a slice from slices table 
# Returns 0 for success or -1 for failure
###################################################################
	def updateSlice(sliceInfo)	
		num = 0
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		slice_id = dbh.prepare("SELECT id FROM slices WHERE id = '#{sliceInfo.values[0]}'")
		slice_id.execute()
		slice_id.fetch do | id |
			sliceInfo.values[1].each do | key, value |
				num = dbh.do("UPDATE slices SET #{key} = '#{value}' WHERE id = '#{id[0]}'")
				my_query.execute()
			end	
		end
		# if one field of the table was updated, its enough
		if (num == 1)	
				return 0
		end
		return -1
	end	

###################################################################
# Updates an existing node reservation
# Returns the reservation's id
###################################################################
	def updateReservedNodes(reservationInfo)
		updated = Array.new
		time1 = Time.parse(reservationInfo.values[1])
		time2 = Time.parse(reservationInfo.values[2])
		if (time1.min != 0 && time1.min != 30 && time1.sec !=0)||(time2.min != 0 && time2.min != 30 && time2.sec !=0)
			puts "False time value. Minutes and seconds must be 00 or 30"
			return -1
		end	
		if (time2.hour-time1.hour > 4)
			puts "False time period. The period should be 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 hours"
			return -1
		end
		if (time2.hour - time1.hour == 4)
				if(time2.min != 0 && time2.min != 0)
					puts "False time period. The period should be 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 hours"
					return -1
				end
		end
		start_time = time1.strftime("%Y-%m-%d %H:%M:%S")
		finish_time = time2.strftime("%Y-%m-%d %H:%M:%S")
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		reservationInfo.values[0].each do | id |
				num = dbh.do("UPDATE reservation SET begin_time='#{start_time}', end_time ='#{finish_time}' WHERE id = '#{id}'")
				if num == 1
						updated.push(id)
				end
		end
		puts updated
		return updated
	end	

###################################################################
# Updates an existing channel reservation
# Returns the reservation's id
###################################################################
	def updateReservedChannels(reservationInfo)	
		updated = Array.new
		time1 = Time.parse(reservationInfo.values[1])
		time2 = Time.parse(reservationInfo.values[2])
		if (time1.min != 0 && time1.min != 30 && time1.sec !=0)||(time2.min != 0 && time2.min != 30 && time2.sec !=0)
			puts "False time value. Minutes and seconds must be 00 or 30"
			return -1
		end	
		if (time2.hour-time1.hour > 4)
			puts "False time period. The period should be 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 hours"
			return -1
		end
		if (time2.hour - time1.hour == 4)
				if(time2.min != 0 && time2.min != 0)
					puts "False time period. The period should be 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 hours"
					return -1
				end
		end
		start_time = time1.strftime("%Y-%m-%d %H:%M:%S")
		finish_time = time2.strftime("%Y-%m-%d %H:%M:%S")
		# connect to the MySQL server
		puts "Connecting to database..."
		dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
		reservationInfo.values[0].each do | id |
				num = dbh.do("UPDATE spec_reserve SET begin_time='#{start_time}', end_time ='#{finish_time}' WHERE id = '#{id}'")
				if num == 1
						updated.push(id)
				end
		end
		puts updated
		return updated
	end	                
end


puts "Setting up the XML-RPC server..."
s  = XMLRPC::Server.new(8081, "#{$server}")
s.add_handler("scheduler.server", Scheduler.new)
s.serve

