#!/usr/bin/env ruby

require 'pdf-reader'
require 'rmagick'

image_suffix = ".jpg"
verbose = true
#latter spelling is a detection issue in PDFs I used
question_page_if_contains = [
"BIOCHEMISTRY /", "BIOCHEMISTRY/", "ANATOMIC SCIENCES", "DENTAL ANATOMY &", 
"copyrig", "copyng", "copyriglrt", "coplri", "codright", "copyrishlil", "coplaight", "copright", "righr", "righl", "'right", "cop\righ", "cotlright", 
"dendecks", "dental decks", "dentaldecks", "dccks", "deneldecks", "decfts", "dertal", "dedta", "ddtal", "dmtal"
]
#question_page_if_contains = "copy"

relative_input_directory = "./raw_pdfs/"
relative_output_directory = "./output/"
pdfs = Dir.entries(relative_input_directory)

pdfs.each do |individual_pdf|

  next if individual_pdf[0] == '.'

  full_path = "#{relative_input_directory}#{individual_pdf}"
  no_suffix_file_name = "#{individual_pdf[0...-4]}"
  text_reader = PDF::Reader.new(full_path)

  #for each PDF, first pass determines which pages are questions
  is_question = Array.new(text_reader.page_count)
  csv_content = ""
  counter = 0 
  puts "Question page if contains #{question_page_if_contains.length} strings..., please set the wright text.include loop!"
  puts "Beginning text read loop" if verbose
  
  text_reader.pages.each do |page|
    text = page.text
#    puts "#{text}"
    if question_page_if_contains.any? {|item| text.include? item} #original code is wrong
#    if text.include?(question_page_if_contains[0]) or text.include?(question_page_if_contains[1]) or text.include?(question_page_if_contains[2]) or text.include?(question_page_if_contains[3]) or text.include?(question_page_if_contains[4]) or text.include?(question_page_if_contains[5]) or text.include?(question_page_if_contains[6]) or text.include?(question_page_if_contains[7]) or text.include?(question_page_if_contains[8]) or text.include?(question_page_if_contains[9]) or text.include?(question_page_if_contains[10]) or text.include?(question_page_if_contains[11]) or text.include?(question_page_if_contains[12]) or text.include?(question_page_if_contains[13]) or text.include?(question_page_if_contains[13]) or text.include?(question_page_if_contains[14]) or text.include?(question_page_if_contains[15]) or text.include?(question_page_if_contains[16]) or text.include?(question_page_if_contains[17]) or text.include?(question_page_if_contains[18]) or text.include?(question_page_if_contains[19]) or text.include?(question_page_if_contains[20]) or text.include?(question_page_if_contains[21]) or text.include?(question_page_if_contains[22]) or text.include?(question_page_if_contains[23]) or text.include?(question_page_if_contains[24]) or text.include?(question_page_if_contains[25]) or text.include?(question_page_if_contains[26])
#    if text.include?(question_page_if_contains[0 || 1 || 2 || 3 || 4 || 5 || 6 || 7 || 8 || 9 || 10 || 11 || 12 || 13 || 14 || 15 || 16 || 17 || 18 || 19 || 20 || 21 || 22 || 23 || 24 || 25 || 26])
      is_question[counter] = true
      puts "#{counter}"
    else
      is_question[counter] = false
    end
    counter += 1
    puts "Page #{counter}" if verbose and (counter % 10 == 0)
  end

  #second pass should create image files 
  #create CSV for export, referring to what images will be called

#  puts "Reading in PDF" if verbose
#  image_reader = Magick::Image.read(full_path) do 
#    self.format = 'PDF'
#    self.quality = 100
#    self.density = 144
#  end

  puts "Beginning csv and image creation" if verbose
  (0..is_question.length-1).each do |n|
    if is_question[n]
      csv_content += "\n" unless csv_content.empty?
    elsif is_question[n-1]
      csv_content += ","
    end
    image_name = "#{no_suffix_file_name}-#{n}#{image_suffix}"
    csv_content += "<img src='#{image_name}'>"
#    image_reader[n].write("#{relative_output_directory}#{image_name}")
    puts "Page #{n}" if verbose and (n % 10 == 0)
  end
  csv_content += "\n"

  File.open("#{relative_output_directory + no_suffix_file_name}.csv", "wb") { |f| f.write(csv_content) }
end
