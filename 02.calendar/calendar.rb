#!/usr/bin/env ruby

require "date"

MonthToStrings = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
MonthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
DayOfWeeks = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
FebruaryLeapYearDays = 29

date = Date.today

# 月の初日の曜日を出す。(日曜日を0として始める)
month_first_day = Date.new(date.year, date.month, 1).wday

# 該当月の日数を出す。
month_days = MonthDays[date.month - 1]

# カレンダーの１マスを１セルと考えて、２次元配列[6][7]のセルを作成する
calendar_array = Array.new( 6 ) { Array.new( 7 , "  " ) }


# 月の日数分だけ繰り返す
(1..month_days).each { | day |

  # 月の開始の曜日分だけ右にずらした後、配列の調整のために1を引く。
  temp = day + month_first_day - 1
  row = temp / 7 # 何週目かを求める
  column = temp % 7 # 何曜日を求める
  # セルの横幅は半角3文字分
  calendar_array[row][column] = "#{day.to_s.rjust(3)}"

}


puts "#{MonthToStrings[date.month - 1]} #{date.year}".center(22)
day_of_week = ""

7.times { | column |

  day_of_week += DayOfWeeks[column].rjust(3)

}

puts day_of_week
output_calendar = Array.new( 8, "" )

6.times { | row |

  calendar_array[row].each { |column|
    output_calendar[row] +=  column
  }
  puts output_calendar[row]

}