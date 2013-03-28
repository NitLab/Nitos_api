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
# == modular architecture
#
# NITOS API v2
#

module DeleteMethods

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
		
		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]
			
			num = dbh.do("DELETE FROM rsa_keys WHERE rsa_keys.key = '#{key}'")
			if (num == 1)	
					return 0
			end
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]
			
			num = dbh.do("DELETE FROM node_list WHERE id = '#{node_id}'")
			if (num == 1)	
					return 0
			end
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]
			
			num = dbh.do("DELETE FROM jos_users WHERE id = '#{user_id}' AND id!='62'")
			if (num == 1)	
					return 0
			end
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]
		
			num = dbh.do("DELETE FROM users_slices WHERE user_id = '#{user_id}' AND slice_id = '#{slice_id}'")
			if (num == 1)	
					return 0
			end
		
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]
		
			num = dbh.do("DELETE FROM slices WHERE id = '#{slice_id}'")
			if (num == 1)	
					return 0
			end
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]
		
			num = dbh.do("DELETE FROM spectrum WHERE id = '#{channel_id}'")
			if (num == 1)	
					return 0
			end
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]
		
			ids.each do | id |
				num = dbh.do("DELETE FROM reservation WHERE id = '#{id}'")
				if num == 1
					deleted.push(id)
				end
			end
		
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]		
		
			ids.each do | id |
				num = dbh.do("DELETE FROM spec_reserve WHERE id = '#{id}'")
				if num == 1
					deleted.push(id)
				end
			end
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
		end
			
		return deleted
	end


end