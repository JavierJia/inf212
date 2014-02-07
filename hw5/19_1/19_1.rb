require './config'

word_freq = top25(extract_word(ARGV[0]))
word_freq.each { |w,f| p "#{w} - #{f}" }
