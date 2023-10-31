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
# スコアボードに得点を代入
1...FRAME_NUM.times do |frame_num|
  score_board[frame_num][0] = input_score[bowl_cnt]
  bowl_cnt += 1
  if frame_num != FRAME_NUM - 1
    # 最終フレームでない場合
    if score_board[frame_num][0] != 10
      # ストライクでない場合、2投目を代入する。
      score_board[frame_num][1] = input_score[bowl_cnt]
      bowl_cnt += 1
    end
  else
    # 最終フレームの場合
    # 2投目は必ず代入する。
    score_board[frame_num][1] = input_score[bowl_cnt]
    bowl_cnt += 1
    # 1投目がストライクまたは、2投目でスペアの場合、3投目を代入する。
    score_board[frame_num][2] = input_score[bowl_cnt] if score_board[frame_num][0] == 10 || score_board[frame_num][0] + score_board[frame_num][1] == 10
  end
end

bowl_cnt = 0
frame_scores = Array.new(FRAME_NUM)
# 各フレームの合計点を計算する。
1...FRAME_NUM.times do |frame_num|
  if frame_num != FRAME_NUM - 1
    # 最終フレームでない場合
    if score_board[frame_num][0] == 10
      # ストライクの場合、後の2投の点を加算する。
      # 投球回数は1回
      frame_scores[frame_num] = score_board[frame_num][0] + input_score[bowl_cnt + 1] + input_score[bowl_cnt + 2]
      bowl_cnt += 1
    elsif score_board[frame_num][0] + score_board[frame_num][1] == 10
      # スペアの場合、後の1投の点を加算する。
      # 投球回数は2回
      frame_scores[frame_num] = score_board[frame_num][0] + score_board[frame_num][1] + input_score[bowl_cnt + 2]
      bowl_cnt += 2
    else
      # ストライクでもスペアでもない場合、フレームの合計値を計算する。
      # 投球回数は2回
      frame_scores[frame_num] = score_board[frame_num].sum
      bowl_cnt += 2
    end
  else
    # 最終フレームの場合
    # フレームの合計値を計算する。
    frame_scores[frame_num] = score_board[frame_num].sum
  end
end

# 全フレームの点数を加算する。
total = frame_scores.sum

# 合計点を出力
puts total
