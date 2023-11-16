#!/usr/bin/env ruby
# frozen_string_literal: true

# 表示列
DISPLAY_COLUMN = 3

def setup_display_array(files)
  display_array = setup_empty_display_array(files)
  max_file_name_length = files.map(&:size).max
  index = 0
  DISPLAY_COLUMN.times do |column|
    display_array.size.times do |row|
      display_array[row][column] = if column != DISPLAY_COLUMN - 1
                                     files[index].ljust(max_file_name_length + 1)
                                   else
                                     display_array[row][column] = files[index]
                                   end
      return display_array if index == files.size - 1

      index += 1
    end
  end
end

def setup_empty_display_array(files)
  quotient, remainder = files.size.divmod(DISPLAY_COLUMN)
  row = if remainder.zero?
          quotient
        else
          quotient + 1
        end
  Array.new(row) { Array.new(DISPLAY_COLUMN, '') }
end

def display_output(displays)
  output_displays = Array.new(displays.size, '')
  displays.size.times do |row|
    DISPLAY_COLUMN.times do |column|
      output_displays[row] = output_displays[row] + displays[row][column]
    end
    puts output_displays[row]
  end
end

files = Dir.glob('*')
display_array = setup_display_array(files)
display_output(display_array)
