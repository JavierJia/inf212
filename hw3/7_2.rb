#!/usr/bin/ruby



def load_stop_word f, set
    word = ''
    while !f.eof && (ch = f.readchar) != ','
        word += ch
    end
    return set if f.eof
    return load_stop_word f, set << word
end

print load_stop_word File.new('../stop_words.txt'),[]

