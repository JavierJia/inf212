#!/usr/bin/ruby

# Here is the Exception to show that the function 
# is runing. The return value is packaged inside the
# exeption. Then the later function can catch or rescue
# the return value and continue to run the code.
class AssertRuning < Exception
    attr_reader :ret
    def initialize ret
        super
        @ret = ret
    end
end

class TFQuarantine
    def initialize 
        @funcs = []
    end

    # Here the bind process doesn't check and exceptions
    # If the function is running, it should failed here.
    def bind func
        @funcs << func
        return self
    end

    def execute 
        def guard_callable v
            (v.is_a? Proc) ? v.call() : v
        end

        # The execute function will run the function
        # Every function should raise an exception,
        # The else part is to verify that each function 
        # should run to the end.
        print @funcs.each_with_object([lambda {nil}]) { |f,v|
            begin
                v[0] = f.call(guard_callable(v[0]))
            rescue AssertRuning => e
                v[0] = e.ret
            else
                raise "The func is not running : " + f.name
            end
        }[0]

    end
end

def get_input args
    raise AssertRuning.new(lambda { return ARGV[0] })
end

def read_file path_to_file
    raise AssertRuning.new(lambda { return File.read(path_to_file) })
end

def filter_chars allwords
    raise AssertRuning.new(allwords.gsub (/[\W_]+/) , ' ')
end

def normalize words
    raise AssertRuning.new(words.downcase)
end

def scan words
    raise AssertRuning.new(words.split)
end

def remove_stop_words words
    raise AssertRuning.new(
    lambda { 
        stopwords = File.read('../stop_words.txt').downcase.split(',')
        return words.reject { |a| stopwords.include? a or a.length < 2 }
    })
end

def frequencies words
    raise AssertRuning.new(words.each_with_object(Hash.new(0)) {|w,h| h[w] +=1; })
end

def sort wf
    raise AssertRuning.new(wf.sort_by {|a| -a[1]})
end

def print_top25 wf
    raise AssertRuning.new((wf.first(25).collect { |k, v| "#{k} - #{v}" }.join "\n") + "\n")
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
