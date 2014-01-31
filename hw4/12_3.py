#!/usr/bin/env python
import sys, re, operator, string

# Auxiliary functions that can't be lambdas
#
def extract_words(obj, path_to_file):
    with open(path_to_file) as f:
        obj['data'] = f.read()
    pattern = re.compile('[\W_]+')
    data_str = ''.join(pattern.sub(' ', obj['data']).lower())
    obj['data'] = data_str.split()

def load_stop_words(obj):
    with open('../stop_words.txt') as f:
        obj['stop_words'] = f.read().split(',')
    # add single-letter words
    obj['stop_words'].extend(list(string.ascii_lowercase))

def increment_count(obj, w):
    obj['freqs'][w] = 1 if w not in obj['freqs'] else obj['freqs'][w]+1

# The calling dict idea and the code is learned from 
# http://stackoverflow.com/questions/3738381/what-do-i-do-when-i-need-a-self-referential-dictionary/3746452#3746452
# if the element is the function, call it with self
class CallingDict(dict):
    def __getitem__(self, item):
        it = super(CallingDict, self).__getitem__(item)
        if callable(it):
            return it(self)
        else:
            return it

# The coresponding method need to return the chained lambda funcion
data_storage_obj = CallingDict({
    'data' : [],
    'init' : lambda self: lambda path_to_file : extract_words(self, path_to_file),
    'words' : lambda self: lambda : self['data']
})

stop_words_obj = CallingDict({
    'stop_words' : [],
    'init' : lambda self: lambda : load_stop_words(self),
    'is_stop_word' : lambda self: lambda word : word in self['stop_words']
})

word_freqs_obj = CallingDict({
    'freqs' : {},
    'increment_count' : lambda self: lambda w : increment_count(self, w),
    'sorted' : lambda self: lambda: sorted(self['freqs'].iteritems(), key=operator.itemgetter(1), reverse=True),
    'top25' : lambda self : lambda : '\n'.join([w + ' - '+ str(c) for (w,c) in self['sorted']()[0:25]])
})

data_storage_obj['init'](sys.argv[1])
stop_words_obj['init']()

for w in data_storage_obj['words']():
    if not stop_words_obj['is_stop_word'](w):
        word_freqs_obj['increment_count'](w)

print word_freqs_obj['top25']()

