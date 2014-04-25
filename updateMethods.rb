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

module UpdateMethods

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
		fields = Array.new
		node_id = 0

		nodeInfo.each_pair { | name, value |
			if(name == "node_id")
				node_id = value
			elsif(name == "fields")
				fields = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$db_ip}","#{$user}", "#{$pass}")
		
			node_id = dbh.prepare("SELECT id FROM node_list WHERE id = '#{node_id}'")
			node_id.execute()
			node_id.fetch do | id |
				fields.each do | key, value |
					num.push(dbh.do("UPDATE node_list SET #{key} = '#{value}' WHERE id = '#{id[0]}'"))
				end	
			end		
			num.each do | i |
				if (num[i] == 1)	
					return 0
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
		
		return -1
	end

###################################################################
# Updates a channel from spectrum table 
# Returns 0 for success or -1 for failure
###################################################################
	def updateChannel(channelInfo)
		num = Array.new
		fields = Array.new
		channel_id = 0

		channelInfo.each_pair { | name, value |
			if(name == "channel_id")
				channel_id = value
			elsif(name == "fields")
				fields = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$db_ip}","#{$user}", "#{$pass}")
		
			channel_id = dbh.prepare("SELECT id FROM spectrum WHERE id = '#{channel_id}'")
			channel_id.execute()
			channel_id.fetch do | id |
				fields.each do | key, value |
					num.push(dbh.do("UPDATE spectrum SET #{key} = '#{value}' WHERE id = '#{id[0]}'"))
				end	
			end
			# if one field of the table was updated, its enough
			num.each do | i |
				if (num[i] == 1)	
					return 0
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
		
		return -1
	end

###################################################################
# Updates a user from users table 
# Returns 0 for success or -1 for failure
###################################################################
	def updateUser(userInfo)
		num = Array.new
		fields = Array.new
		user_id = 0

		userInfo.each_pair { | name, value |
			if(name == "user_id")
				user_id = value
			elsif(name == "fields")
				fields = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$db_ip}","#{$user}", "#{$pass}")
		
			user_id = dbh.prepare("SELECT id FROM nitlab.b9tj1_users WHERE id = '#{user_id}'")
			user_id.execute()
			user_id.fetch do | id |
				fields.each do | key, value |
					num.push(dbh.do("UPDATE nitlab.b9tj1_users SET #{key} = '#{value}' WHERE id = '#{id[0]}'"))
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
# Updates a slice from slices table 
# Returns 0 for success or -1 for failure
###################################################################
	def updateSlice(sliceInfo)	
		num = 0
		fields = Array.new
		slice_id = 0

		sliceInfo.each_pair { | name, value |
			if(name == "slice_id")
				slice_id = value
			elsif(name == "fields")
				fields = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$db_ip}","#{$user}", "#{$pass}")
		
			slice_id = dbh.prepare("SELECT id FROM slices WHERE id = '#{slice_id}'")
			slice_id.execute()
			slice_id.fetch do | id |
				fields.each do | key, value |
					num = dbh.do("UPDATE slices SET #{key} = '#{value}' WHERE id = '#{id[0]}'")
				end	
			end
			# if one field of the table was updated, its enough
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
# Updates an existing node reservation
# Returns the reservation's id
###################################################################
	def updateReservedNodes(reservationInfo)
		updated = Array.new
		ids = Array.new
		startime = 0
		endtime = 0

		reservationInfo.each_pair { | name, value |
			if(name == "reservation_ids")
				ids = value
			elsif(name == "start_time")
				startime = value
			elsif(name == "end_time")
				endtime = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}

		time1 = Time.parse(startime)
		time2 = Time.parse(endtime)
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
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$db_ip}","#{$user}", "#{$pass}")
		
			ids.each do | id |
				num = dbh.do("UPDATE reservation SET begin_time='#{start_time}', end_time ='#{finish_time}' WHERE id = '#{id}'")
				if num == 1
					updated.push(id)
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
		
		puts updated
		return updated
	end	

###################################################################
# Updates an existing channel reservation
# Returns the reservation's id
###################################################################
	def updateReservedChannels(reservationInfo)	
		updated = Array.new
		ids = Array.new
		startime = 0
		endtime = 0

		reservationInfo.each_pair { | name, value |
			if(name == "reservation_ids")
				ids = value
			elsif(name == "start_time")
				startime = value
			elsif(name == "end_time")
				endtime = value
			else
				puts "wrong parameter: #{name}"
				return "wrong parameter: #{name}"
			end				
		}
		time1 = Time.parse(startime)
		time2 = Time.parse(endtime)
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
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$db_ip}","#{$user}", "#{$pass}")
			
			ids.each do | id |
				num = dbh.do("UPDATE spec_reserve SET begin_time='#{start_time}', end_time ='#{finish_time}' WHERE id = '#{id}'")
				if num == 1
					updated.push(id)
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
		
		puts updated
		return updated
	end	                


end
