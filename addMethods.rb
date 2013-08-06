
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
# == modular architecture
#
# NITOS API v2
#

module AddMethods

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
	
		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]
			
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

			# Reservation while being in the active time slot
			node_y = 0
			now = Time.now
			puts now
			# execute enable_node for reservations in the active time slot
			final_reserved.each do | id |
				if (start_time < now) && (now < finish_time)
					my_query = dbh.prepare("SELECT y FROM node_list WHERE id = '#{id}'")
					result = my_query.execute()
					my_query.fetch do | y |
						node_y = y
					end
					puts node_y

					cmd = `enable_node #{slice_name} #{node_y}`
				end
			end

			# insert values into the database
			i = 0
			final_reserved.each do | id |
				puts id
				id = id.to_i
				puts id
				dbh.do("INSERT INTO reservation (username,begin_time,end_time,node_id) VALUES ('#{slice_name[0]}','#{start_time}','#{finish_time}','#{id}')")
				final_reserved[i] = id
				i += 1
			end
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]
		
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
				dbh.do("INSERT INTO spec_reserve (username,begin_time,end_time,spectrum_id) VALUES ('#{slice_name[0]}','#{start_time}','#{finish_time}','#{id}')")
					final_reserved[i] = id
					i += 1
			end
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
		end	
			
		return final_reserved
	end

##################################################################
# Adds a new user into users table
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]
		
			dbh.do("INSERT INTO b9tj1_users (username) VALUES ('#{username}')")
			id = dbh.prepare("SELECT id FROM b9tj1_users WHERE username = '#{username}'")
			id.execute()
			id.fetch do | n |
				new_id = n[0]
			end
			my_query = dbh.prepare("UPDATE b9tj1_users SET email = '#{email}' WHERE id = '#{new_id}'")
			my_query.execute()
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
		end	
			
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
		
		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]		
		
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
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]

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
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]		
				
			dbh.do("INSERT INTO slices (slice_name) VALUES ('#{slice_name}')")
			id = dbh.prepare("SELECT id FROM slices WHERE slice_name = '#{slice_name}'")
			id.execute()
			id.fetch do | n |
				new_id = n[0]
			end
			# create OMF pubsub node into the xmpp server
			value = `create_slice #{slice_name} nitlab.inf.uth.gr`
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]
		
			dbh.do("INSERT INTO node_list (name,type,floor,view,wall,X,Y,Z) VALUES ('#{hostname}','#{node_type}','#{floor}','#{view}','#{wall}','#{position.values[0]}','#{position.values[1]}','#{position.values[2]}')")
			id = dbh.prepare("SELECT id FROM node_list WHERE name = '#{hostname}'")
			id.execute()
			id.fetch do | n |
				new_id = n[0]
			end
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]
		
			dbh.do("INSERT INTO spectrum (channel) VALUES ('#{channel}')")
			id = dbh.prepare("SELECT id FROM spectrum WHERE channel = '#{channel}'")
			id.execute()
			id.fetch do | n |
				new_id = n[0]
			end
			num = dbh.do("UPDATE spectrum SET frequency = '#{frequency}', modulation = '#{modulation}' WHERE id = '#{new_id}'")
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
		end	
			
		return new_id
	end

end
