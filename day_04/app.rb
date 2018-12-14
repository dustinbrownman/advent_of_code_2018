require "time"

filename = ARGV[0]

logbook = {}
guard_sleep_log = {}

File.open(filename, "r") do |file|
    file.each_line do |line|
        /\[(?<date>.*)\]\W(?<log>.*)/ =~ line.to_s
        logbook[date] = log
    end
end

state = {
    current_guard: nil,
    current_minute: 0,
    asleep: false
}

def process_guard_change(log, state)
    /#(?<guard_id>\d+)/ =~ log

    return unless guard_id

    state[:current_guard]  = guard_id
    state[:current_minute] = 0
    state[:asleep]         = false
end

def process_sleeping(log, state)
    return unless log.match("falls asleep")
    state[:asleep] = true
end

def process_waking(log, state)
    return unless log.match("wakes up")
    state[:asleep] = false
end

def record_sleep_log(guard, minute, log)
    log[guard] ||= Hash.new(0)
    log[guard][minute] += 1
end

logbook.sort.each_cons(2) do |(_time, log), (next_time, _next_log)|
    process_guard_change(log, state)
    process_sleeping(log, state)
    process_waking(log, state)

    next_minute = Time.parse(next_time).min

    while next_minute != state[:current_minute]
        record_sleep_log(state[:current_guard], state[:current_minute], guard_sleep_log) if state[:asleep]
        state[:current_minute] = (state[:current_minute] + 1) % 60
    end
end

sleeping_stats = {}

guard_sleep_log.map do |guard, sleeping_log|
    total_sleeping_time = sleeping_log.values.inject(:+)

    sleeping_stats[guard] = [total_sleeping_time, sleeping_log]
end

sorted_stats = sleeping_stats.sort_by { |_guard, (count, _log)| count }

biggest_sleeper, (_sleeping_count, log_of_minutes_asleep) = sorted_stats.last

sleepiest_minute = log_of_minutes_asleep.sort_by { |_minute, asleep_count| asleep_count }.last[0]


puts biggest_sleeper.to_i * sleepiest_minute
