#!/usr/bin/ruby

def read_file filename, word_freqs, filter_func
    words = File.read(filename)
    filter_func.call words, word_freqs, method(:normalize)
end

def filter words, word_freqs, normalize_func
    normalize_func.call words.gsub(/[\W_]+/, ' '), word_freqs, method(:scan)
end

def normalize words, word_freqs, scan_func
    scan_func.call words.downcase, word_freqs, method(:remove_stop_word)
end

def scan words, word_freqs, remove_stop_word_func
    remove_stop_word_func.call  words.split, word_freqs, method(:frequecies)
end

def remove_stop_word words, word_freqs, frequecies_func
    stopwords = File.read('../stop_words.txt').downcase.split(',')
    frequecies_func.call words.reject {|a| stopwords.include? a or a.length < 2}, 
        word_freqs, method(:sort)
end

def frequecies words, word_freqs, sort_func
    wf = words.each_with_object(Hash.new(0)) { |w, h| h[w] +=1;}
    sort_func.call wf, word_freqs, method(:print_top)
end

def sort wf, word_freqs, print_top_func
    print_top_func.call wf.sort_by {|a| -a[1]}, method(:no_op)
end

def print_top word_freqs, no_op_func
    no_op_func.call(word_freqs.first(25), nil).each { |k,v| puts "#{k} - #{v}"}
end

def no_op word_freqs, nil_func
    return word_freqs
end

read_file ARGV[0], [], method(:filter)
