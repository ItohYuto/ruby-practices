#!/usr/bin/env ruby
require 'optparse'
require "date"

options = ARGV.getopts('m:y:')

DayOfWeeks = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]


# カレンダーの曜日と日にちを生成する関数
def generate_calendar(year, month)
  # 月の初日の曜日を出す。(日曜日を0として始める)
  month_first_day = Date.new(year, month, 1).wday
  # 該当月の日数を出す。
  month_days = Date.new(year, month, -1).mday

  # カレンダーの１マスを１セルと考えて、２次元配列[6][7]のセルを作成する
  calendar_array = Array.new( 7 ) { Array.new( 7 , "   " ) }
  # 配列の1行目に曜日を設定する。
  7.times { | column |
  calendar_array[0][column] = DayOfWeeks[column].rjust(3)
  }

  # 月の日数分だけ繰り返す
  (1..month_days).each { | day |
    # 月の開始の曜日分だけ右にずらした後、配列の調整のために1を引く。
    temp = day + month_first_day - 1
    row = temp / 7 # 何週目かを求める
    column = temp % 7 # 何曜日を求める
    # セルの横幅は半角3文字分
    calendar_array[row + 1][column] = "#{day.to_s.rjust(3)}"
  }

  output_calendar = Array.new( 7, "" )
  0..7.times { | row |
    calendar_array[row].each { |column|
      output_calendar[row] += column
    }
  }
  output_calendar
end

date = Date.today
month = date.month
year = date.year

if options["y"] != nil
  year = options["y"].to_i
end

if options["m"] != nil
  month = options["m"].to_i
end

err = false;

# 入力チェック
# 年の有効範囲(1~9999以内)
if ( year > 9999 ) || ( year < 1 )
  err_sentence = "year `#{year}' not in range 1..9999"
  err = true
# 月の有効範囲(1~12以内)
elsif ( month > 12 ) || ( month < 1 )
  err_sentence = "#{month} is neither a month number (1..12) nor a name"
  err = true
end

abort err_sentence if err
# 年月の表示用文字列を生成
output_year_month = "#{Date.new(year, month, 1).strftime("%B")} #{year}".center(22)
# カレンダーを生成
output_calendar = generate_calendar(year, month)

puts output_year_month
7.times { | row |
  puts output_calendar[row]
}
