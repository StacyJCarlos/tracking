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
			end
			#return a string of the formatted elapsed time
			case format
			when :colons
				elapsed = ""
				elapsed += "%02d:" % hours if hours
				if $config[:show_elapsed_seconds]
					elapsed += "%02d:" % minutes if minutes
				else
				end
				if seconds
					elapsed += "%02d" % seconds if $config[:show_elapsed_seconds]
					if minutes
						elapsed += "%02d" % minutes + $config[:show_elapsed_seconds] ? " " : ""
						if hours
							elapsed += "#{hours.to_s}h "
							if days
								elapsed += "%02d:" % days
							end
						end
					elsif seconds == 0
						elapsed = ""
					end
				end
				return elapsed
			when :letters
				elapsed = ""
				if seconds
					elapsed += "#{seconds.to_s}s" if $config[:show_elapsed_seconds]
					if minutes
						elapsed += "#{minutes.to_s}m" + $config[:show_elapsed_seconds] ? " " : ""
						if hours
							elapsed += "#{hours.to_s}h "
							if days
								elapsed += "#{days.to_s}d "
							end
						end
					elsif seconds == 0
						elapsed = ""
					end
				end
				return elapsed
			end
		end

	end
end
