#!/usr/bin/ruby

class TheOne
    def initialize val
        @val = val
    end

    def bind func
        @val = func.call(@val)
        return self
    end

    def printme 
        puts @val
    end
end

def read_file path_to_file
    return File.read(path_to_file)
end

def filter_chars allwords
    return allwords.gsub /[\W_]+/,' '
end

def normalize words
    return words.downcase
end

def scan words
    return words.split
end

def remove_stop_words words
    stopwords = File.read('../stop_words.txt').downcase.split(',')
    return words.reject { |a| stopwords.include? a or a.length < 2 }
end

def frequencies words
    return words.each_with_object(Hash.new(0)) {|w,h| h[w] +=1; }
end

def sort wf
    return wf.sort_by {|a| -a[1]}
end

def print_top25 wf
    return wf.first(25).collect { |k, v| "#{k} - #{v}" }.join "\n"
end

TheOne.new(ARGV[0]).bind(method(:read_file))
                .bind(method(:filter_chars))
                .bind(method(:normalize))
                .bind(method(:scan))
                .bind(method(:remove_stop_words))
                .bind(method(:frequencies))
                .bind(method(:sort))
                .bind(method(:print_top25))
                .printme
