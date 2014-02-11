#!/usr/bin/ruby

class TheOne
    def initialize val
        @val = val
        @e = nil
        @func = nil
    end

    def bind func
        if @e == nil
            begin
                @val = func.call(@val)
            rescue Exception => e
                @e = e
                @func = func
            end
        end
        return self
    end

    def printme 
        if @e == nil
            puts @val 
        else
            puts @e.message + " in " + @func.name.to_s
        end
    end
end

def get_input args
    raise "I need an input file! I quit!" if args.length < 1
    return args[0]
end

def read_file path_to_file
    raise "I need a string! I quit!" unless path_to_file.is_a? String
    raise "I need a non-empty string! I quit!" unless path_to_file.length > 0
    return File.read(path_to_file)
end

def filter_chars allwords
    raise "I need a string! I quit!" unless allwords.is_a? String
    return allwords.gsub (/[\W_]+/) , ' '
end

def normalize words
    raise "I need a string! I quit!" unless words.is_a? String
    return words.downcase
end

def scan words
    raise "I need a string! I quit!" unless words.is_a? String
    return words.split
end

def remove_stop_words words
    raise "I need a list! I quit!" unless words.is_a? Array
    stopwords = File.read('../stop_words.txt').downcase.split(',')
    return words.reject { |a| stopwords.include? a or a.length < 2 }
end

def frequencies words
    raise "I need a list! I quit!" unless words.is_a? Array
    return words.each_with_object(Hash.new(0)) {|w,h| h[w] +=1; }
end

def sort wf
    raise "I need a dictionary! I quit!" unless wf.is_a? Hash
    return wf.sort_by {|a| -a[1]}
end

def print_top25 wf
    raise "I need a list! I quit!" unless wf.is_a? Array
    return wf.first(25).collect { |k, v| "#{k} - #{v}" }.join "\n"
end

TheOne.new(ARGV).bind(method(:get_input))
                .bind(method(:read_file))
                .bind(method(:filter_chars))
                .bind(method(:normalize))
                .bind(method(:scan))
                .bind(method(:remove_stop_words))
                .bind(method(:frequencies))
                .bind(method(:sort))
                .bind(method(:print_top25))
                .printme
