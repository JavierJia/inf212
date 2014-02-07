require "word_extractor_2/version"

def extract_word path_to_file
    words = File.read(path_to_file).downcase.scan(/[a-z]{2,}/) 
    stopwords = File.read('../stop_words.txt').downcase.split(',')
    return words.reject { |a| stopwords.include? a }
end
