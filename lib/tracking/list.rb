#Tracking's core.

#imports
require "yaml"
require "time"
require "csv"
require "fastercsv"

#model/controller module methods
module Tracking
	module List

		extend self

		Config = YAML.load_file(ENV["HOME"] + "/.tracking/config.yml")
		$data_file = File.expand_path(Config[:data_file])
		$csv_options = { :col_sep => "\t" }

		#adds an item to the list
		def add item
			date = Time.now.to_s
			csv = get_csv_lib
			File.open($data_file, "a") do |file|
					file << csv.generate_line([ date, item ], $csv_options)
			end
		end

		#deletes an item from the list
		def delete
			lines = File.readlines $data_file
			lines.pop #or delete specific lines in the future
			csv = get_csv_lib
			csv.open($data_file, "w", $csv_options) do |file| 
				lines.each do |line|
					file.puts [ line ]
				end
			end
		end

		#clears the entire list
		def clear
			FileUtils.rm $data_file
			FileUtils.touch $data_file
		end

		#gets and formats the amount of time passed between two times
		def get_elapsed_time(time1, time2)
			#calculate the elapsed time and break it down into different units
			seconds = (time2 - time1).floor
			minutes = hours = days = 0
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
			case Config[:elapsed_format]
			when :colons
				if Config[:show_elapsed_seconds]
					return "%02d:%02d:%02d:%02d" % [days, hours, minutes, seconds]
				else
					return "%02d:%02d:%02d" % [days, hours, minutes]
				end
			when :letters
				if Config[:show_elapsed_seconds]
					return "%02dd %02dh %02dm %02ds" % [days, hours, minutes, seconds]
				else
					return "%02dd %02dh %02dm" % [days, hours, minutes]
				end
			end
		end

		#grabs the right CSV lib for the current version of Ruby
		def get_csv_lib
			if CSV.const_defined? :Reader
				return FasterCSV
			else
				return CSV
			end
		end

	end
end
