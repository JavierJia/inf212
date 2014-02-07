require "frequencies_1/version"

def top25 word_list
    wf = word_list.each_with_object(Hash.new(0)) {|w,h| h[w] +=1;}
    return wf.sort_by {|a| -a[1]}.first(25)
end
