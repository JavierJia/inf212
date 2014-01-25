#!/usr/bin/ruby

def load_stop_word f, set
    word = ''
    while !f.eof and (ch = f.readchar) != ','
        word += ch.to_s
    end
    return set if f.eof
    return load_stop_word f, set << word
end

print load_stop_word File.new('../stop_words.txt'),[]
puts

