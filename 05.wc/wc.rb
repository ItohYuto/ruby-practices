#!/usr/bin/env ruby
# frozen_string_literal: true

LOG_OPTION_JUDGE_PATTERN = /^total\s+[0-9]*\n$/

OPTION_NAMES = %i[lines words bytes].freeze
TAB_WIDTH = 7

class WcOption
  require 'optparse'
  attr_reader :options

  def initialize
    @options = {}
    @options.default = false
    OptionParser.new do |opt|
      opt.on('-c', '--bytes', 'print the byte counts') { @options[:bytes] = true }
      opt.on('-l', '--lines', 'print the newline counts') { @options[:lines] = true }
      opt.on('-w', '--words', 'print the word counts') { @options[:words] = true }
      opt.parse!(ARGV)
      OPTION_NAMES.each { |key| @options[key] = true } if @options.none?
    end
  end
end

def get_word_count_parameters(strings, file_paths = [''])
  word_count_params = []
  strings.each_with_index do |string, i|
    word_count_param = {}
    word_count_param[:lines] = string.lines.count
    word_count_param[:words] = string.split(/\s+/).size
    word_count_param[:bytes] = string.bytesize
    word_count_param[:file_path] = file_paths[i]
    word_count_params << word_count_param
  end
  word_count_params
end

def calc_total(word_count_params)
  word_count_param = {}
  OPTION_NAMES.each { |key| word_count_param[key] = word_count_params.sum { |params| params[key] } }
  word_count_param[:file_path] = 'total'
  word_count_param
end

def calc_max_length_per_params(word_count_params)
  max_length = {}
  OPTION_NAMES.each do |key|
    max_length[key] = word_count_params.max_by { |params| params[key].to_s.length }[key].to_s.length
  end
  max_length
end

def result_output(word_count_params, string_length, option)
  word_count_params.each do |word_count_param|
    OPTION_NAMES.each do |key|
      next if !option.options[key]

      print word_count_param[key].to_s.rjust(string_length)
      print ' '
    end
    print word_count_param[:file_path]
    puts
  end
end

option = WcOption.new
file_paths = ARGV
strings = []
if file_paths.any?
  file_paths.each do |file_path|
    next if !File.stat(file_path).file?

    strings << File.read(file_path)
  end
elsif File.pipe?($stdin)
  strings << $stdin.read
  is_stdin = true
end
word_count_params = get_word_count_parameters(strings, file_paths)
word_count_params << calc_total(word_count_params) if !word_count_params.one?

max_length_per_params = calc_max_length_per_params(word_count_params)
output_length = if option.options.one?
                  0
                elsif is_stdin
                  TAB_WIDTH
                else
                  max_length_per_params.values.max
                end
result_output(word_count_params, output_length, option)
