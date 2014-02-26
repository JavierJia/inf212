#!/usr/bin/ruby

def partition data_str, nlines
    data_str.split(/\n/).each_slice(nlines).map { |nline| yield nline}
end

def split_word lines
    stop_words = File.read('../stop_words.txt').downcase.split(',')
    lines.each_with_object([]) do |line, result|
        line.downcase.scan(/[a-z]{2,}/).each do |word|
            if not stop_words.include? word
                result << [word, 1]
            end
        end
    end
end

def shuffle partial_list
    result = partial_list.each_with_object(Hash.new) do |tuple, hash|
        hash[tuple[0]] = Array.new unless hash.has_key? tuple[0]
        hash[tuple[0]] << tuple
    end
    result.to_a
end

def reduce value
    [value[0], value[1].reduce(0) { |sum,pair| sum += pair[1] }]
end

# map
sub_result = []
partition(File.read(ARGV[0]), 200) do |part|
    sub_result.concat( split_word(part))
end

# shuffle
shufferd = shuffle sub_result

# reduce
shufferd.map!{ |value| reduce value}

shufferd.sort_by {|element| -element[1]}.first(25).each do |struct|
    puts "#{struct[0]} - #{struct[1]}"
end
