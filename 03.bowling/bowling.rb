#!/usr/bin/env ruby
# frozen_string_literal: true

# フレーム数：10
FRAME_NUM = 10
# １フレームの投球数：2
BOWL_NUM = 2
# 引数の入力を取得（区切り文字','で配列に代入する。）
input = ARGV[0].split(',')
input_score = []
# そのままだとStringクラスのため数値に変換。
# この時、Xは10に変換する。
input.each do |val|
  if val == 'X'
    input_score.push(10)
  else
    input_score.push(val.to_i)
  end
end

# 2次元配列を作成し、10フレーム分のスコアボードを作成。（１０フレーム目は投球数が最大３のため配列を１つ追加）
score_board = Array.new(FRAME_NUM) { Array.new(BOWL_NUM, 0) }
score_board[9].push(0)
bowl_cnt = 0
total = 0

(1..FRAME_NUM).each do |frame_num|
  total += input_score[bowl_cnt]
  bowl_cnt += 1
  if frame_num != FRAME_NUM
    # 最終フレームでない場合
    if input_score[bowl_cnt - 1] != 10
      # ストライクでない場合、2投目を代入する。
      total += input_score[bowl_cnt]
      bowl_cnt += 1
      total += input_score[bowl_cnt] if input_score[bowl_cnt - 2] + input_score[bowl_cnt - 1] == 10
    else
      total += input_score[bowl_cnt] + input_score[bowl_cnt + 1]
    end
  else
    # 最終フレームの場合
    # 2投目は必ず代入する。
    total += input_score[bowl_cnt]
    bowl_cnt += 1
    # 1投目がストライクまたは、2投目でスペアの場合、3投目を代入する。
    total += input_score[bowl_cnt] if input_score[bowl_cnt - 2] == 10 || input_score[bowl_cnt - 2] + input_score[bowl_cnt - 1] == 10
  end
end

# 合計点を出力
puts total
