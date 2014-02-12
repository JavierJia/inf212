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

        @funcs.each_with_object([lambda {nil}]) { |f,v|
            v[0] = f.call(guard_callable(v[0]))
        }

    end
end

def get_input args
    lambda { return ARGV[0] }
end

def read_file path_to_file
    lambda { return File.read(path_to_file) }
end

def filter_chars allwords
    allwords.gsub (/[\W_]+/) , ' '
end

def normalize words
    words.downcase
end

def scan words
    words.split
end

def remove_stop_words words
    lambda { 
        stopwords = File.read('../stop_words.txt').downcase.split(',')
        return words.reject { |a| stopwords.include? a or a.length < 2 }
    }
end

def frequencies words
    words.each_with_object(Hash.new(0)) {|w,h| h[w] +=1; }
end

def sort wf
    wf.sort_by {|a| -a[1]}
end

def print_top25 wf
    lambda {
        wf.first(25).collect { |k, v| puts "#{k} - #{v}" }
    }
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
            .bind(lambda {|v|})  # do nothing
            .execute
