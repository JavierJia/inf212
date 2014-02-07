require "word_extractor_1/version"

def extract_word path_to_file
    words = File.read(path_to_file).downcase.split(/[\W_]+/).reject {|a| a.length < 2 }
    stopwords = File.read('../stop_words.txt').downcase.split(',')
    return words.reject { |a| stopwords.include? a }
end
