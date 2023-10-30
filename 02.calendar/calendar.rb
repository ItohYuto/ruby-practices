#!/usr/bin/env ruby
require 'optparse'
require "date"

options = ARGV.getopts('m:y:')

MonthToStrings = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
MonthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
DayOfWeeks = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
FebruaryLeapYearDays = 29


# カレンダーの曜日と日にちを生成する関数
def generate_calendar(year, month)
  # 月の初日の曜日を出す。(日曜日を0として始める)
  month_first_day = Date.new(year, month, 1).wday
  # 該当月の日数を出す。
  if year % 4 == 0 && month == 2
    # うるう年の判定
    month_days = FebruaryLeapYearDays
  else
    month_days = MonthDays[month - 1]
  end

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

# 年月の表示用文字列を生成する関数
def generate_year_month(year, month)
  sentance = "#{MonthToStrings[month - 1]} #{year}".center(22)
  sentance
end

date = Date.today
month = date.month
year = date.year

err = false;

# 入力チェック
# 年の有効範囲(1~9999以内)
if ( year > 9999 ) || ( year < 1 )
  puts "year `#{year}' not in range 1..9999"
  err = true
# 月の有効範囲(1~12以内)
elsif ( month > 12 ) || ( month < 1 )
  puts "#{month} is neither a month number (1..12) nor a name"
  err = true
end

if err == false
  if options["y"] != nil
    year = options["y"].to_i
  end

  if options["m"] != nil
    month = options["m"].to_i
  end

  output_year_month = generate_year_month(year, month)
  output_calendar = generate_calendar(year, month)

  puts output_year_month
  7.times { | row |
    puts output_calendar[row]
  }
end
