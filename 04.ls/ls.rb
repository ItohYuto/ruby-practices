#!/usr/bin/env ruby
# frozen_string_literal: true

MAX_COLUMN = 3

def align_files(files)
  aligned_files = setup_empty_array(files)
  max_file_name_length = files.map(&:size).max
  files.each_with_index do |file, index|
    column, row = index.divmod(aligned_files.size)
    aligned_files[row][column] = file.ljust(max_file_name_length + 1)
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
  Array.new(row) { Array.new(MAX_COLUMN, '') }
end

def output_files(aligned_files)
  aligned_files.size.times do |row|
    MAX_COLUMN.times do |column|
      print aligned_files[row][column]
    end
    puts
  end
end

files = Dir.glob('*')
aligned_files = align_files(files)
output_files(aligned_files)
