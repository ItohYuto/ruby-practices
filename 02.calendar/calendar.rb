#!/usr/bin/env ruby
require 'optparse'
require "date"

options = ARGV.getopts('m:y:')

DAY_OF_WEEKS = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]


# カレンダーの曜日と日にちを生成する関数
def generate_calendar(year, month)
  # 月の初日の曜日を出す。(日曜日を0として始める)
  month_first_day = Date.new(year, month, 1).wday
  # 該当月の日数を出す。
  month_days = Date.new(year, month, -1).mday

  days = (1..month_days).to_a
  month_first_day.times {
    days.unshift("")
  }
  calendar_array = [[]]
  # 配列の1行目に曜日を設定。
  calendar_array[0] = DAY_OF_WEEKS.map { |day| day.rjust(3)}
  days.each_slice(7) { |week|
    calendar_array << week.map { |day| day.to_s.rjust(3) }
  }
  calendar_array
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
abort "year `#{year}' not in range 1..9999" if ( year > 9999 ) || ( year < 1 )
abort "#{month} is neither a month number (1..12) nor a name" if ( month > 12 ) || ( month < 1 )

# 生成処理
output_year_month = "#{Date.new(year, month, 1).strftime("%B")} #{year}".center(22)
output_calendar = generate_calendar(year, month)

# 出力処理
puts output_year_month
output_calendar.each { |week|
  week.each { |day|
    print day
  }
  puts
}
