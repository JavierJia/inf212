#!/usr/bin/ruby

stop_words = File.read('../stop_words.txt').downcase.split(',')

worker_queue = Queue.new
collector_queue = Queue.new

File.read(ARGV[0]).downcase.scan(/[a-z]{2,}/).each {|word| worker_queue << word }

workers = 5.times.each_with_object([]) do |i, ary|
    ary << Thread.new {
        sub_freq = Hash.new(0)
        loop do
            begin 
                word = worker_queue.pop(true) # blocking if empty
                sub_freq[word] +=1 unless stop_words.include? word
            rescue ThreadError
                break
            end
        end
        collector_queue << sub_freq
    }
end

workers.each { |w| w.join}

merged_freq = Hash.new(0)
until collector_queue.empty? do
    sub_freq = collector_queue.pop(true) 
    merged_freq.merge!( sub_freq) {|key,oldv,newv| newv + oldv }
end

merged_freq.sort_by {|e| -e[1]}.first(25).each {|k,v| puts "#{k} - #{v} " }

