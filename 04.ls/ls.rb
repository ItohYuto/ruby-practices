#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'
MAX_COLUMN = 3
FILE_TYPE_MAP = {
  '01' => 'p',
  '02' => 'c',
  '04' => 'd',
  '06' => 'b',
  '10' => '-',
  '12' => 'l',
  '14' => 's'
}.freeze
PERMISSION_TYPE_MAP = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

class LsOption
  require 'optparse'

  def initialize
    @options = {}
    OptionParser.new do |opt|
      opt.on('-a', '--all', 'do not ignore entries starting with .') { @options[:all] = true }
      opt.on('-r', '--reverse', 'reverse order while sorting') { @options[:reverse] = true }
      opt.on('-l', 'use a long listing format') { @options[:long_format] = true }
      opt.parse!(ARGV)
    end
  end

  def has?(name)
    @options.include?(name)
  end
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

def align_files(files)
  aligned_files = setup_empty_array(files)
  files.each_with_index do |file, index|
    column, row = index.divmod(aligned_files.size)
    aligned_files[row][column] = file
  end
  aligned_files
end

def long_format_files(sorted_files)
  long_format_files = [[]]
  sorted_files.each_with_index do |file, i|
    file_stat = File.stat(file)
    long_format_files[i] << format_filemode(file_stat.mode.to_s(8))
    long_format_files[i] << file_stat.nlink.to_s
    long_format_files[i] << Etc.getpwuid(file_stat.uid).name
    long_format_files[i] << Etc.getgrgid(file_stat.gid).name
    long_format_files[i] << file_stat.size.to_s
    long_format_files[i] << file_stat.mtime.strftime('%b %d %H:%M')
    long_format_files[i] << file
    long_format_files << [] if i != sorted_files.length - 1
  end
  long_format_files
end

def change_width_by_column(aligned_files, space_num)
  cahnged_width_files = [[]]
  transposed_aligned_files = aligned_files.transpose
  transposed_aligned_files.size.times do |column|
    max_string_length = transposed_aligned_files[column].map(&:size).max
    transposed_aligned_files[column].each_with_index do |string, row|
      cahnged_width_files[column][row] = string.ljust(max_string_length + space_num)
    end
    cahnged_width_files << [] if column != transposed_aligned_files.length - 1
  end
  cahnged_width_files.transpose
end

def output_files(cahnged_width_files)
  cahnged_width_files.each do |rows|
    rows.each do |string|
      print string
    end
    puts
  end
end

def format_filemode(filemode)
  filemode.prepend('0') if filemode.length == 5
  file_type = FILE_TYPE_MAP[filemode.slice(0..1)]
  file_permission = filemode.slice(-3..-1).split(//).map { |n| PERMISSION_TYPE_MAP[n] }
  "#{file_type}#{file_permission.join('')}"
end

def judcge_special_permission(decision_char, file_permission)
  case decision_char
  when '1'
    file_permission[2] = if file_permission[2].slice(2) == 'x'
                           file_permission[2].gsub(/.$/, 't')
                         else
                           file_permission[2].gsub(/.$/, 'T')
                         end
  when '2'
    file_permission[1] = if file_permission[1].slice(2) == 'x'
                           file_permission[1].gsub(/.$/, 's')
                         else
                           file_permission[1].gsub(/.$/, 'S')
                         end
  when '4'
    file_permission[0] = if file_permission[0].slice(2) == 'x'
                           file_permission[0].gsub(/.$/, 's')
                         else
                           file_permission[0].gsub(/.$/, 'S')
                         end
  end
end

option = LsOption.new

files = []
Dir.foreach('.') do |file|
  next if !option.has?(:all) && file.match?(/\A\.{1,2}/)

  files << file
end
sorted_files = files.sort_by { |filename| filename.delete_prefix('.').downcase }
sorted_files.reverse! if option.has?(:reverse)
aligned_files = if option.has?(:long_format)
                  space_num = 1
                  long_format_files(sorted_files)
                else
                  space_num = 2
                  align_files(sorted_files)
                end
cahnged_width_files = change_width_by_column(aligned_files, space_num)
output_files(cahnged_width_files)
