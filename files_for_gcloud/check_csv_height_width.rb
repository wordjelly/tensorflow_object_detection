require "csv"
require "json"


raise "please provide a file path for the csv file" unless ARGV[0]

iterator = 0
column_names = {}

errors = []

CSV.foreach(ARGV[0]) do |row|
	if iterator == 0
		
		indices = row.map.with_index{|c,i| c = i}
		
		column_names = Hash[indices.zip(row)]
	
	else
	
		row_with_column_names = Hash[column_names.values.zip(row)]
	
		if row_with_column_names["xmin"].to_i > row_with_column_names["width"].to_i
			
			errors << ["xmin is greater than width",row_with_column_names.to_s]

		elsif row_with_column_names["xmax"].to_i > row_with_column_names["width"].to_i
			
			errors << ["xmax is greater than width",row_with_column_names.to_s]
		
		elsif row_with_column_names["ymin"].to_i > row_with_column_names["height"].to_i
			
			errors << ["ymin is greater than height",row_with_column_names.to_s]
		
		elsif row_with_column_names["ymax"].to_i > row_with_column_names["height"].to_i
			
			errors << ["ymax is greater than height",row_with_column_names.to_s]
		
		else
		
		end
	
	end
	iterator+=1
end

puts "iterator :#{iterator}"
puts JSON.pretty_generate(errors)