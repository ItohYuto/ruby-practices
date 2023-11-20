#!/usr/bin/env ruby
# frozen_string_literal: true

MAX_COLUMN = 3

def align_files(files)
  aligned_files = setup_empty_array(files)
  files.each_with_index do |file, index|
    column, row = index.divmod(aligned_files[0].size)
    aligned_files[column][row] = file
  end
  aligned_files
end

def setup_empty_array(files)
  quotient, remainder = files.size.divmod(MAX_COLUMN)
  row = if remainder.zero?
          quotient
        else
          quotient + 1
        end
  Array.new(MAX_COLUMN) { Array.new(row, '') }
end

def change_width_by_column(aligend_files)
  cahnged_width_files = [[]]
  MAX_COLUMN.times do |column|
    max_file_name_length = aligend_files[column].map(&:size).max
    aligend_files[column].each_with_index do |file, row|
      cahnged_width_files[column][row] = file.ljust(max_file_name_length + 2)
    end
    cahnged_width_files << [] if column != MAX_COLUMN - 1
  end
  cahnged_width_files
end

def output_files(cahnged_width_files)
  cahnged_width_files[0].size.times do |row|
    MAX_COLUMN.times do |column|
      print cahnged_width_files[column][row]
    end
    puts
  end
end

files = Dir.glob('*')
aligned_files = align_files(files)
cahnged_width_files = change_width_by_column(aligned_files)
output_files(cahnged_width_files)
