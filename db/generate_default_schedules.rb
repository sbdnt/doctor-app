puts "Generating default schedules ..."
7.times do |i|
  Schedule.create(start_time: Date.today + 8.hours, end_time: Date.today + 23.hours, week_day: i)
end
periods_each_schedule =  (TimeDifference.between(Schedule.first.start_time, Schedule.first.end_time).in_minutes/15 + 1)
periods_each_schedule.to_i.times do |i|
  Period.create(schedule_id: Schedule.first.id, 
                duration: 15, start_at: Date.today + 8.hours + i*15.minutes, 
                end_at: Date.today + 8.hours + (i+1)*15.minutes)
end