#!/usr/bin/env ruby
# frozen_string_literal: true

LOG_OPTION_JUDGE_PATTERN = /^total\s+[0-9]*\n$/

class WcOption
  require 'optparse'

  def initialize
    @options = {}
    OptionParser.new do |opt|
      opt.on('-c', '--bytes', 'print the byte counts') { @options[:bytes] = true }
      opt.on('-l', '--lines', 'print the newline counts') { @options[:lines] = true }
      opt.on('-w', '--words', 'print the word counts') { @options[:words] = true }
      opt.parse!(ARGV)
    end
  end

  def has?(name)
    @options.include?(name)
  end

  def none?
    @options.none?
  end
end

def get_word_count_parameters(string, file_path = '')
  word_count_param = {}
  word_count_param[:lines] = string.lines.count.to_s
  word_count_param[:words] = string.split(/\s+/).size.to_s
  word_count_param[:bytes] = string.bytesize.to_s
  word_count_param[:file_path] = file_path
  word_count_param
end

def calc_total(word_count_params)
  word_count_param = {}
  word_count_param[:lines] = word_count_params.sum { |params| params[:lines].to_i }.to_s
  word_count_param[:words] = word_count_params.sum { |params| params[:words].to_i }.to_s
  word_count_param[:bytes] = word_count_params.sum { |params| params[:bytes].to_i }.to_s
  word_count_param[:file_path] = 'total'
  word_count_param
end

def calc_max_length_per_params(word_count_params)
  max_length = {}
  word_count_params[0].each_key do |key|
    next if key == :file_path

    tmp_length = 0
    max_length[key] = word_count_params.each do |params|
      tmp_length = tmp_length >= params[key].length ? tmp_length : params[key].length
    end
    max_length[key] = tmp_length
  end
  max_length
end

option = WcOption.new
output_params = { lines: false, words: false, bytes: false }

if option.none?
  output_params = { lines: true, words: true, bytes: true }
else
  output_params[:lines] = true if option.has?(:lines)
  output_params[:words] = true if option.has?(:words)
  output_params[:bytes] = true if option.has?(:bytes)
end

file_paths = ARGV
word_count_params = []
if file_paths.any?
  file_paths.each_with_index do |file_path, i|
    next if !File.stat(file_path).file?

    string = File.read(file_path)
    word_count_params[i] = get_word_count_parameters(string, file_path)
    word_count_params << [] if i != file_paths.size - 1
  end
  word_count_params << calc_total(word_count_params) if !word_count_params.one?

  max_length_per_params = calc_max_length_per_params(word_count_params)
  output_length = if output_params.values.one?
                    max_length_per_params[output_params.key(true)]
                  else
                    output_length = max_length_per_params.values.max
                  end
elsif File.pipe?($stdin)
  string = $stdin.read
  word_count_params << get_word_count_parameters(string)
  max_length_per_params = calc_max_length_per_params(word_count_params)

  output_length = if output_params.values.one?
                    max_length_per_params[output_params.key(true)]
                  else
                    output_length = max_length_per_params.values.max + 4
                  end
end

word_count_params.each do |word_count_param|
  if output_params[:lines]
    print word_count_param[:lines].rjust(output_length)
    print ' '
  end
  if output_params[:words]
    print word_count_param[:words].rjust(output_length)
    print ' '
  end
  if output_params[:bytes]
    print word_count_param[:bytes].rjust(output_length)
    print ' '
  end
  print word_count_param[:file_path] if !word_count_param[:file_path].nil?
  puts
end
