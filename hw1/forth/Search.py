
stack = []
heap = {}

def frequencies_forth_style():
    """
    Takes a list of words and returns a dictionary associating
    words with frequencies of occurrence.
    """
    heap['word_freqs'] = {}
    # A little flavour of the real Forth style here...
    while len(stack) > 0:
        stack.append(1) # Push 1 in stack[2]
        for (key, val) in heap['word_freqs']:
            if stack[-1] != key:
                continue
            # Increment the frequency, postfix style: f 1 +
            stack.append(val) # push f
            stack.append(1) # push 1
            stack.append(stack.pop() + stack.pop()) # add
            break

        # Load the updated freq back onto the heap
        heap['word_freqs'][stack.pop()] = stack.pop()  

    # Push the result onto the stack
    stack.append(heap['word_freqs'])
    del heap['word_freqs'] # We dont need this variable anymore

