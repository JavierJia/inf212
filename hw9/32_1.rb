#!/usr/bin/ruby

class WordFrequencyModel
    attr_reader :freqs

    def initialize 
        @stop_words = File.read('../stop_words.txt').downcase.split(',')
        @views = []
    end

    def reg_view view
        @views << view
    end
    
    def update filename
        @freqs = File.read(filename).downcase.scan(/[a-z]{2,}/).each_with_object(Hash.new(0)) do |word, hash|
            hash[word] += 1 unless @stop_words.include? word
        end
        @views.each { |v| v.render }
    end

end

class WordFrequencyView

    def initialize model
        @model = model
        @model.reg_view self
    end

    def render 
        @model.freqs.sort_by {|a| -a[1]}.first(25).each do |w, f|
            puts "#{w} - #{f}"
        end
        puts "======================="
    end
end

class WordFrequencyController

    def initialize model
        @model = model
    end

    def run 
        loop do
            puts "Please type your filename: ('q' or 'quit' to quit)"
            puts "Hints:" + Dir.glob('../*.txt').each_with_object([]) {|f,a| a<< f.to_s }.to_s
            filename = gets.strip
            break if filename == 'q' or filename== 'quit' or filename.length == 0
            @model.update filename
        end
        puts "bye"
    end
end

m = WordFrequencyModel.new
v = WordFrequencyView.new m
c = WordFrequencyController.new m
c.run

