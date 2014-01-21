#!/usr/bin/ruby

stopwords = File.read('../stop_words.txt').downcase.split(',')
words = File.read(ARGV[0]).downcase.split(/[\W_]+/).reject {|a| a.length == 0 }
couter = words.reject { |a| stopwords.include? a }.inject(Hash.new(0)) { |h,v| h[v]+=1; h;}
couter.sort_by { |a| -a[1] }.first(25).each { |k,v| puts "#{k} - #{v}"}

