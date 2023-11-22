#!/usr/bin/env ruby
# frozen_string_literal: true

MAX_COLUMN = 3

class LsOption
  require 'optparse'

  def initialize
    @options = {}
    OptionParser.new do |opt|
      opt.on('-a', '--all', 'do not ignore entries starting with .') { @options[:all] = true }
      opt.on('-r', '--reverse', 'reverse order while sorting') { @options[:reverse] = true }
      opt.parse!(ARGV)
    end
  end

  def has?(name)
    @options.include?(name)
  end
end

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

option = LsOption.new

files = []
Dir.foreach('.') do |file|
  next if !option.has?(:all) && file.match?(/\A\.{1,2}/)

  files << file
end
sorted_files =
  if option.has?(:reverse)
    files.sort_by { |filename| filename.delete_prefix('.').downcase }.reverse
  else
    files.sort_by { |filename| filename.delete_prefix('.').downcase }
  end
aligned_files = align_files(sorted_files)
cahnged_width_files = change_width_by_column(aligned_files)
output_files(cahnged_width_files)
