filename = ARGV[0]

original_sequence = File.read(filename)

def react!(sequence)
    reaction_matcher = /([a-zA-Z])(?!\1)(?i:\1)/

    sequence.gsub!(reaction_matcher, "")
end

def perform_reactions!(sequence)
    loop do
        sequence_length = sequence.length
        
        react!(sequence)
        break if sequence_length == sequence.length
    end

    sequence
end

### Part 1 ###

input_sequence = original_sequence.dup

perform_reactions!(input_sequence)

puts input_sequence.length

### Part 2 ###

results = {}

("a".."z").each do |letter|
    test_sequence = original_sequence.gsub(/#{letter}/i, "")

    perform_reactions!(test_sequence)

    results[letter] = test_sequence.length

    puts "#{letter} : #{test_sequence.length}"
end

shortest_sequence = results.sort_by { |_letter, count| count }.first

puts shortest_sequence[1]
