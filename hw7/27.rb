#!/usr/bin/ruby

def lines filename
    File.foreach(filename).each {|line| yield line}
end

def all_words filename
    lines (filename) do |line|
        line.gsub((/[\W_]+/),' ').downcase.split.each { |word| yield word}
    end
end

def non_stop_words filename
    stop_words = File.read('../stop_words.txt').downcase.split(',')
    all_words filename do |word|
        yield word unless stop_words.include? word
    end
end

def frequencies filename
    freq, i = Hash.new(0), 0
    non_stop_words filename do |word|
        freq[word]+=1
        yield freq if i % 5000 == 0
        i+=1
    end
    yield freq
end

def sort filename
    frequencies filename do |hash|
        yield hash.sort_by { |a| -a[1]}
    end
end

sort ARGV[0] do |hash| 
    puts "-----------------------------"
    hash.first(25).each {|w,f| puts "#{w} - #{f}"}
end

