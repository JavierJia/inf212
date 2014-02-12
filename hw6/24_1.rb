#!/usr/bin/ruby

class TFQuarantine
    def initialize 
        @funcs = []
    end

    def bind func
        @funcs << func
        return self
    end

    def execute 
        def guard_callable v
            (v.is_a? Proc) ? v.call() : v
        end

        print @funcs.each_with_object([lambda {return nil}]) { |f,v|
            v[0] = f.call(guard_callable(v[0]))
        }[0]

    end
end

def get_input args
    return lambda { return ARGV[0] }
end

def read_file path_to_file
    return lambda { return File.read(path_to_file) }
end

def filter_chars allwords
    return allwords.gsub (/[\W_]+/) , ' '
end

def normalize words
    return words.downcase
end

def scan words
    return words.split
end

def remove_stop_words words
    return lambda { 
        stopwords = File.read('../stop_words.txt').downcase.split(',')
        return words.reject { |a| stopwords.include? a or a.length < 2 }
    }
end

def frequencies words
    return words.each_with_object(Hash.new(0)) {|w,h| h[w] +=1; }
end

def sort wf
    return wf.sort_by {|a| -a[1]}
end

def print_top25 wf
    return (wf.first(25).collect { |k, v| "#{k} - #{v}" }.join "\n") + "\n"
end

TFQuarantine.new().bind(method(:get_input))
            .bind(method(:read_file))
            .bind(method(:filter_chars))
            .bind(method(:normalize))
            .bind(method(:scan))
            .bind(method(:remove_stop_words))
            .bind(method(:frequencies))
            .bind(method(:sort))
            .bind(method(:print_top25))
            .execute
