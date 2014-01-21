#!/usr/bin/ruby

RubyVM::InstructionSequence.compile_option = {
    :tailcall_optimization => true,
    :trace_instruction => false
}

$stopwords = File.read('../stop_words.txt').downcase.split(',')
words = File.read(ARGV[0]).downcase.split(/[\W_]+/).reject {|a| a.length == 0 }
STACK_DEPTH = 5000

def count word_list,word_freq
    if word_list != nil and word_list.length > 0
        word_freq[word_list[0]] +=1 unless $stopwords.include? word_list[0]
        count(word_list[1..-1], word_freq)
    end
end

freqs = Hash.new(0)
(0..words.size).step(STACK_DEPTH).each do |i|
    count words[i..(i+STACK_DEPTH)], freqs
end

freqs.sort_by { |a| -a[1] }.first(25).each { |k,v| puts "#{k} - #{v}"}
