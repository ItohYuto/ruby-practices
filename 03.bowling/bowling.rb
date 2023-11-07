#!/usr/bin/env ruby
# frozen_string_literal: true

FRAME_NUM = 10
BOWL_NUM = 2

input = ARGV[0].split(',')
input_score = []

input_score =
  input.map do |val|
    if val == 'X'
      10
    else
      val.to_i
    end
  end

bowl_cnt = 0
total = 0

(1..FRAME_NUM).each do |frame_num|
  total += input_score[bowl_cnt]
  bowl_cnt += 1
  if frame_num != FRAME_NUM
    if input_score[bowl_cnt - 1] != 10
      total += input_score[bowl_cnt]
      bowl_cnt += 1
      total += input_score[bowl_cnt] if input_score[bowl_cnt - 2] + input_score[bowl_cnt - 1] == 10
    else
      total += input_score[bowl_cnt] + input_score[bowl_cnt + 1]
    end
  else
    total += input_score[bowl_cnt]
    bowl_cnt += 1
    total += input_score[bowl_cnt] if input_score[bowl_cnt - 2] == 10 || input_score[bowl_cnt - 2] + input_score[bowl_cnt - 1] == 10
  end
end

puts total
