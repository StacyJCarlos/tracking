#Tracking's core.

#imports
require "yaml"
require "time"
require "csv"

#model/controller module methods
module Tracking
	module List

		extend self

		$config = YAML.load_file(ENV["HOME"] + "/.tracking/config.yml")
		$config[:data_file] = File.expand_path($config[:data_file])
		$data_file = CSV.open($config[:data_file], "r+", {:col_sep => "\t"})

		#adds an item to the list
		def add item
			date = Time.now.to_s
			$data_file << [ date, item ]
		end

		#deletes an item from the list
		def delete
			lines = $data_file.readlines
			#lines = File.readlines($config[:data_file])
			lines.pop #or delete specific lines in the future
			#File.open($config[:data_file], "w") do |f| 
			$data_file.write do |f| 
				lines.each do |line|
					f.puts line
				end
			end
		end

		#clears the entire list
		def clear
			FileUtils.rm $config[:data_file]
			FileUtils.touch $config[:data_file]
		end

		#opens the list data file in a text editor
		def edit
			system ENV["EDITOR"] + " " + $config[:data_file]
		end

		#gets and formats the amount of time passed between two times
		def get_elapsed_time(time1, time2, format=:colons)
			#calculate the elapsed time and break it down into different units
			seconds = (time2 - time1).floor
			minutes, hours, days = 0
			if seconds >= 60
				minutes = seconds / 60
				seconds = seconds % 60
				if minutes >= 60
					hours = minutes / 60
					minutes = minutes % 60
					if hours >= 24
						days = hours / 24
						hours = hours % 24
					end
				end
			elsif seconds == 0
				seconds = nil
			end
			#return a string of the formatted elapsed time
			case format
			when :colons
				elapsed = ""
				elapsed += "%02d:" % days if days
				elapsed += "%02d:" % hours if hours
				elapsed += "%02d:" % minutes if minutes
				elapsed += "%02d" % seconds if seconds
			when :letters
				elapsed = ""
				elapsed += "#{days.to_s}d " if days
				elapsed += "#{hours.to_s}h " if hours
				elapsed += "#{minutes.to_s}m " if minutes
				elapsed += "#{seconds.to_s}s" if seconds
			else
				elapsed = ""
			end
			return elapsed
		end

		def format_elapsed_time(seperator, items)
			seconds = items[:seconds]
			minutes = items[:minutes]
			hours   = items[:hours]
			days    = items[:days]
			seconds_suffix = items[:seconds_suffix]
			minutes_suffix = items[:minutes_suffix]
			hours_suffix   = items[:hours_suffix]
			days_suffix    = items[:days_suffix]
			elapsed = ""
			elapsed += days.to_s    + separator if days
			elapsed += hours.to_s   + separator if hours or days
			elapsed += minutes.to_s + separator if minutes or hours or days
			elapsed += seconds.to_s + separator if seconds or minutes or hours or days
			return elapsed
		end

	end
end
