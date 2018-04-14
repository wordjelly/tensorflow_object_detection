require 'rmagick'

## @param[String] directory : the directory where the image files are located.
## @param[String] prefix : the prefix to add to each image file name.
## @params[String] extensions : should be something like : jpg|png|xml, any regex metacharacters are interpreted as is.
## will prepend "#{prefix}_" to each file in the directory.
def rename_files(directory,prefix,extensions)
	Dir.glob(directory + "/*").sort.each do |entry|
	  if File.extname(entry)=~/(#{extensions})$/i
	    newEntry = File.dirname(entry) + "/" + prefix + "_" + File.basename(entry)
	    puts "renaming :#{entry} => #{newEntry}"
	    File.rename( entry, newEntry )
	  end
	end
end

## lets move all of them into one folder, first, and there we will rename?
## how to rename exactly?


## @param[String] prefix : a prefix to add to the filenames in the xml file.
## @param[String] label : the new label to be used for each entry in the xml file.
def modify_xml_labels(category_dir,directory,extensions)
	Dir.glob(directory + "/*").sort.each do |entry|
	  if File.extname(entry)=~/(#{extensions})$/i
	    #newEntry = File.dirname(entry) + "/" + prefix + "_" + File.basename(entry)
	    #puts "renaming :#{entry} => #{newEntry}"
	    #File.rename( entry, newEntry )
	  	## xml read the file.
	  	text = IO.read(entry)
	  	## now the folder is to be got
	  	## and it is to be changed.
	  	## then also the rest.
	  	folder_name = nil
	  	#puts "the text is:"
	  	#puts text.to_s
	  	text.scan(/\<folder\>(?<folder_name>[a-z]+)\<\/folder\>/) { |match|  
	  		folder_name = match[0]
	  	}	
	  		
	  	file_name = nil	

	  	text.gsub!(/\<filename\>(?<file_name>([a-zA-Z\.\-0-9_])+)\<\/filename\>/) { |match|
	  		match_data = Regexp.last_match
	  		file_name = match_data[:file_name]
	  		match = "<filename>#{folder_name}_#{file_name}</filename>"
	  	}
	  	
	  	path = nil
	  	text.gsub!(/\<path\>(?<path>([a-zA-Z\.\-0-9\/_])+)\<\/path\>/){|match|
	  		
	  		#if file_name[0..1] == (folder_name + "_")
	  		#match = "<path>/home/bhargav/Pictures/analysis/stage_for_gcloud/training_images/#{file_name}</path>"
	  		#else
	  		match = "<path>/home/bhargav/Pictures/analysis/stage_for_gcloud/training_images/#{folder_name}_#{file_name}</path>"
	  		#end
	  	}
	  	

	  	## what about the folder ?
	  	## how are we going to do the folder here ?
	  	## folder is trainig images.
	  	text.gsub!(/\<folder\>(?<folder_name>[a-z]+)\<\/folder\>/) { |match|  
	  		match = "<folder>training_images</folder>"
	  	}	
	  	
	  	IO.write(category_dir + "/train_xml_paths_modified/" + File.basename(entry),text)

	  end
	end
end	


def rename_jpg_to_png(directory)
	Dir.glob(directory + "/*").sort.each do |entry|
	  if File.extname(entry)=~/(jpg)$/i
	    newEntry = File.dirname(entry) + "/" + File.basename(entry, File.extname(entry)) + ".png"
	    puts "renaming :#{entry} => #{newEntry}"
	    File.rename( entry, newEntry )
	  end
	end
end



def update_height_and_width_in_xml_files(directory)
	Dir.glob(directory + "/*").sort.each do |entry|
	    unless entry=~/c_1.xml/
		  	if File.extname(entry)=~/(xml)$/i
			  	text = IO.read(entry)
			  	width = nil
			  	height = nil
			  	folder = nil
			  	filename = nil
			  	correct_image_path = nil
			  	text.scan(/\<path\>(?<path>([a-zA-Z\.\-0-9\/])+)\<\/path\>/){|match|
			  		match_data = Regexp.last_match
			  		path = match_data[:path]
			  		## path is wrong.
			  		## it should be 
			  		## path is 
			  		## /home/bhargav/Pictures/analysis/c/c_1.jpg
			  		basename = File.basename(path)
			  		basename = "c_" + basename
			  		correct_image_path = "/home/bhargav/Pictures/analysis/c/" + basename
			  		correct_image_path = File.dirname(correct_image_path) + "/" + File.basename(correct_image_path, File.extname(correct_image_path)) + ".png"
					img = Magick::Image.ping(correct_image_path).first
					width = img.columns
					height = img.rows
			  		folder = "c"
			  		filename = File.basename(correct_image_path)
			  	}


			  	text.gsub!(/\<path\>([a-zA-Z\.\-0-9\/])+\<\/path\>/) { |match|  
			  		match = "<path>#{correct_image_path}</path>"
			  	}

			  	text.gsub!(/\<folder\>([a-zA-Z\.\-0-9\/])+\<\/folder\>/) { |match|  
			  		match = "<folder>#{folder}</folder>"
			  	}

				text.gsub!(/\<filename\>([a-zA-Z\.\-0-9\/])+\<\/filename\>/) { |match|  
			  		match = "<filename>#{filename}</filename>"
			  	}

			  	text.gsub!(/\<width\>([a-zA-Z\.\-0-9\/])+\<\/width\>/) { |match|  
			  		match = "<width>#{width}</width>"
			  	}

			  	text.gsub!(/\<height\>([a-zA-Z\.\-0-9\/])+\<\/height\>/) { |match|  
			  		match = "<height>#{height}</height>"
			  	}	  	
			  		
			  	#puts text.to_s
			  	IO.write(entry,text)
			  	#exit(1)
		  	end
		end
	end
end

=begin

rename_files('/home/bhargav/Pictures/analysis/nails','nails','jpg|png')
rename_files('/home/bhargav/Pictures/analysis/nails/train','nails','xml')
=end

#rename_jpg_to_png('/home/bhargav/Pictures/analysis/c')
#update_height_and_width_in_xml_files('/home/bhargav/Pictures/analysis/c/train')

modify_xml_labels('/home/bhargav/Pictures/analysis/c','/home/bhargav/Pictures/analysis/c/train','xml')