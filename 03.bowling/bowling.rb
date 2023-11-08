#!/usr/bin/env ruby
# frozen_string_literal: true

MAX_FRAME_NUM = 10
MAX_PIN_NUM = 10

inputs = ARGV[0].split(',')
input_points = []

input_points =
  inputs.map do |val|
    if val == 'X'
      MAX_PIN_NUM
    else
      val.to_i
    end
  end

bowl_cnt = 0
total = 0

(1..MAX_FRAME_NUM).each do |frame_num|
  total += input_points[bowl_cnt]
  bowl_cnt += 1
  if frame_num != MAX_FRAME_NUM
    if input_points[bowl_cnt - 1] != MAX_PIN_NUM
      total += input_points[bowl_cnt]
      bowl_cnt += 1
      total += input_points[bowl_cnt] if input_points[bowl_cnt - 2] + input_points[bowl_cnt - 1] == MAX_PIN_NUM
    else
      total += input_points[bowl_cnt] + input_points[bowl_cnt + 1]
    end
  else
    total += input_points[bowl_cnt]
    bowl_cnt += 1
    total += input_points[bowl_cnt] if input_points[bowl_cnt - 2] == MAX_PIN_NUM || input_points[bowl_cnt - 2] + input_points[bowl_cnt - 1] == MAX_PIN_NUM
  end
end

puts total
