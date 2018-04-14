require "csv"
require "json"
require "rmagick"

class String
  def numeric?
    Float(self) != nil rescue false
  end
end

iterator = 0
column_names = {}

CSV.foreach(ARGV[0]) do |row|
	
	if iterator == 0
		
		indices = row.map.with_index{|c,i| c = i}
		
		column_names = Hash[indices.zip(row)]

	else
	
		row_with_column_names = Hash[column_names.values.zip(row.map{|c| 
			c = c.numeric? ? c.to_i : c.to_s
		})]
		
		filename = row_with_column_names["filename"]
		image_name = File.basename(filename, File.extname(filename)) 
		full_path = "/home/bhargav/Pictures/analysis/stage_for_gcloud/training_images/#{filename}"
		img = Magick::Image.read(full_path)[0]
		x = row_with_column_names["xmin"]
		y = row_with_column_names["ymin"]
		width = row_with_column_names["xmax"] - x
		height = row_with_column_names["ymax"] - y
		
		cropped = img.crop(x, y, width, height)
		
		subdir = nil
		if image_name=~/^k/
			subdir = "k"
		elsif image_name =~/^c/
			subdir = "c"
		elsif image_name =~/^b/
			subdir = "b"
		elsif image_name =~/^n/
			subdir = "n"
		else
			subdir = "misc"
		end

		cropped_name = ARGV[1] + "/#{subdir}/" +  image_name + "_dimensions_#{x}_#{y}_#{width}_#{height}" + File.extname(filename)
		
		#puts cropped_name.to_s
		puts iterator.to_s
		cropped.write(cropped_name)
		
	end

	iterator+=1

end