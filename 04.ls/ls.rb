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

def output_long_format_files(files, total, max_length_per_property)
  puts "total #{total}"
  files.each do |properties|
    print "#{properties[:filemode].ljust(max_length_per_property[:filemode])} "
    print "#{properties[:nlink].rjust(max_length_per_property[:nlink])} "
    print "#{properties[:owner_username].ljust(max_length_per_property[:owner_username])} "
    print "#{properties[:user_groupname].ljust(max_length_per_property[:user_groupname])} "
    print "#{properties[:size].rjust(max_length_per_property[:size])} "
    print "#{properties[:timestamp].ljust(max_length_per_property[:timestamp])} "
    print "#{properties[:filename].ljust(max_length_per_property[:filename])} "
    puts
  end
end

def get_files_properties(files)
  long_format_files = []
  files.each_with_index do |file, i|
    file_stat = File.stat(file)
    properties = {}
    properties[:filemode] = format_filemode(file_stat.mode.to_s(8))
    properties[:nlink] = file_stat.nlink.to_s
    properties[:owner_username] = Etc.getpwuid(file_stat.uid).name
    properties[:user_groupname] = Etc.getgrgid(file_stat.gid).name
    properties[:size] = file_stat.size.to_s
    properties[:timestamp] = file_stat.mtime.strftime('%b %d %H:%M')
    properties[:filename] = file
    # File::statで取得しているブロック数はブロックサイズが512Byteだが、
    # lsコマンドのデフォルトのブロックサイズは1024Byteのため、lsコマンドに合わせるため2で割る
    properties[:blocks] = file_stat.blocks / 2
    long_format_files[i] = properties
    long_format_files << [] if i != files.length - 1
  end
  long_format_files
end

def format_filemode(filemode)
  filemode.prepend('0') if filemode.length == 5
  file_type = FILE_TYPE_MAP[filemode.slice(0..1)]
  file_permission = filemode.slice(-3..-1).split(//).map { |n| PERMISSION_TYPE_MAP[n] }
  "#{file_type}#{file_permission.join('')}"
end

def judge_special_permission(decision_char, file_permission)
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

def align_itemized_properties(files_with_properties)
  aligned_itemized_properties = []
  files_with_properties.each_with_index do |items, i|
    aligned_itemized_properties << if [1, 4].include?(i)
                                     align_string_length(items, 'right')
                                   else
                                     align_string_length(items)
                                   end
  end
  aligned_itemized_properties.transpose
end

def calc_max_length_per_property(files_with_properties)
  max_length = {}
  files_with_properties[0].each_key do |key|
    tmp_length = 0
    max_length[key] = files_with_properties.each do |properties|
      tmp_length = tmp_length >= properties[key].length ? tmp_length : properties[key].length
    end
    max_length[key] = tmp_length
  end
  max_length
end

option = LsOption.new

files = []
total = 0 if option.has?(:long_format)
Dir.foreach('.') do |file|
  total += 1 if option.has?(:long_format)
  next if !option.has?(:all) && file.match?(/\A\.{1,2}/)

  files << file
end
sorted_files = files.sort_by { |filename| filename.delete_prefix('.').downcase }
sorted_files.reverse! if option.has?(:reverse)

if option.has?(:long_format)
  files_with_properties = get_files_properties(sorted_files)
  total = files_with_properties.sum { |properties| properties.delete(:blocks) }
  max_length_per_property = calc_max_length_per_property(files_with_properties)
  output_long_format_files(files_with_properties, total, max_length_per_property)
else
  aligned_files = align_files(sorted_files)
  cahnged_width_files = change_width_by_column(aligned_files)
  output_files(cahnged_width_files)
end
