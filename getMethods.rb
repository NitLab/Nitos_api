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

module GetMethods

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
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
  
		if retValue.empty? && filter.empty? 
			my_query = dbh.prepare("SELECT name, id, type, floor, view, wall, x, y, z FROM node_list order by name")
			my_query.execute()	
			final = Struct.new(:hostname,:node_id,:node_type,:floor,:view,:wall,:position)
			pos = Struct.new(:X,:Y,:Z)
			pos_result = Array.new
			i=0
			my_query.fetch do | n |
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
#					my_query[i] = dbh.prepare("SELECT #{value} FROM node_list ORDER BY name")
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
#	if n[0] != "node006" && n[0] != "node010" && n[0] != "node022" && n[0] != "node024" && n[0] != "node028" && n[0] != "node031"
					pos_result[i] = pos.new("#{n[6]}","#{n[7]}","#{n[8]}")
					final_result[i] = final.new("#{n[0]}","#{n[1]}","#{n[2]}","#{n[3]}","#{n[4]}","#{n[5]}",pos_result[i])
					puts final_result[i]
					i=i+1
					j=j+1
#				end # end filtering
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
		
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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
		puts "Connecting to database..."
		begin
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

		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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
		
		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")
			# get server version string and display it
			row = dbh.select_one("SELECT VERSION()")
			puts "Server version: " + row[0]
			
#			if retValue.empty? && filter.empty? 
			final = Struct.new(:slice_id,:slice_name,:user_ids)
			my_query = dbh.prepare("SELECT id, slice_name FROM slices")
			my_query.execute()				
			i=0
			my_query.fetch do | n |
				# get users for this slice
				my_query = dbh.prepare("SELECT b9tj1_users.id FROM b9tj1_users, users_slices WHERE b9tj1_users.id=users_slices.user_id AND users_slices.slice_id='#{n[0]}'")
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

		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")		
			
			# get the time now
			time = Time.new
			now = time.strftime("%Y-%m-%d %H:%M:%S") 
#			if retValue.empty? && filter.empty? 
			final = Struct.new(:reservation_id,:slice_id,:start_time,:end_time,:node_id)
			# select only the active reservations. Those that have not expired
my_query = dbh.prepare("SELECT id, username, unix_timestamp(begin_time), unix_timestamp(end_time), node_id FROM reservation WHERE end_time>'#{now}'")
#my_query = dbh.prepare("SELECT id, username, unix_timestamp(begin_time), unix_timestamp(end_time), node_id FROM reservation WHERE begin_time>='20130401'")
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
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")			
			
			# get the time now
			time = Time.new
			now = time.strftime("%Y-%m-%d %H:%M:%S")
			final = Struct.new(:reservation_id,:slice_id,:start_time,:end_time,:channel_id)
			# select only the active reservations. Those that have not expired...
my_query = dbh.prepare("SELECT id, username, unix_timestamp(begin_time), unix_timestamp(end_time), spectrum_id FROM spec_reserve WHERE end_time>'#{now}'")
#my_query = dbh.prepare("SELECT id, username, unix_timestamp(begin_time), unix_timestamp(end_time), node_id FROM reservation WHERE end_time>='20130401'")
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

		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
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

		puts "Connecting to database..."
		begin
			# connect to the MySQL server
			dbh = DBI.connect("DBI:Mysql:#{$db}:#{$server}","#{$user}", "#{$pass}")			
			
			my_query = dbh.prepare("SELECT id, username, email FROM b9tj1_users WHERE block='0'")
			my_query.execute()				
			i=0
			my_query.fetch do | n |
				# get keys for this user
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
			
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		ensure
			# disconnect from server
			dbh.disconnect if dbh
		end			
			
		puts "#{final_result}"
		final_result
	end

###################################################################			
# Returns information about the testbed
###################################################################
	def getTestbedInfo()
		final = Struct.new(:name,:grain,:OMF_version,:scheduler_version,:gw_address,:longitude,:latitude)
		final_result = final.new("nitos","1800","5.4","1.0","nitlab.inf.uth.gr","39.360839","22.949989")			
		puts "result: #{final_result}"
		final_result
	end

###################################################################			
# Returns time in the server
###################################################################
	def getServerTime()
		# get the time now
		time = Time.now.to_i
		time
	end

end
