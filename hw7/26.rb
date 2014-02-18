#!/usr/bin/ruby

data_file = [ nil, lambda {data_file[0]} ] 
stopword_file = [ "../stop_words.txt", lambda {stopword_file[0]}]

all_words = [ nil, lambda { 
    File.read(data_file[0]).gsub((/[\W_]+/), ' ').downcase.split } ]
stop_words = [ nil, lambda { 
    File.read(stopword_file[0]).downcase.split(',')} ]

non_stop_words = [ nil, lambda { 
    all_words[0].reject {|w| stop_words[0].include? w or w.length < 2 }} ]

frequencies = [nil, lambda {
    non_stop_words[0].each_with_object(Hash.new(0)) {|w,h| h[w]+=1;}} ]

sort = [nil, lambda { frequencies[0].sort_by {|a| -a[1]}} ]

print = [nil, lambda { sort[0].first(25).collect {|k,v| puts "#{k} - #{v}"}}]

all_columns = [ data_file, stopword_file, all_words, stop_words, non_stop_words,
                frequencies, sort, print ]

def update all
    all.each { |data| data[0] = data[1].call }
end

loop do 
    puts "Please type your filename:('q' or 'quit' to quit)"
    puts "Hints:" + Dir.glob('../*.txt').each_with_object([]) {|f,a| a<< f.to_s }.to_s
    data_file[0] = gets.strip
    break if data_file[0]== 'q' or data_file[0]== 'quit' or data_file[0].length == 0
    begin 
        update all_columns
    rescue IOError => e
        p e.message
    end
end

puts 'Bye'
