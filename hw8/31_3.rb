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

def regrouping partial_list
    partial_list.each_with_object(Array.new(5){[]}) do |tuple, grouped|
        word = tuple[0]
        idx = case word[0]
            when 'a'..'e' then 0
            when 'f'..'j' then 1
            when 'k'..'o' then 2
            when 'p'..'t' then 3
            else 4
        end
        grouped[idx] << tuple
    end
end

def reduce value
    value.reduce(Hash.new(0)) { |hash, pair| hash[pair[0]] += pair[1]; hash}.to_a
end

# map
sub_result = []
partition(File.read(ARGV[0]), 200) do |part|
    sub_result.concat( split_word(part))
end

# regrouping
grouped = regrouping sub_result

# reduce
grouped.map!{ |value| reduce value}

grouped.flatten(1).sort_by {|element| -element[1]}.first(25).each do |struct|
    puts "#{struct[0]} - #{struct[1]}"
end
