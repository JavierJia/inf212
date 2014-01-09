CC=g++
CFLAGS=-c -g -Wall -Wextra
SOURCES=good-old-time.cpp
OBJECTS=$(SOURCES:.cpp=.o)
EXECUTABLE=oldtime

all: $(SOURCES) $(EXECUTABLE)
		
$(EXECUTABLE): $(OBJECTS) 
		$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.cpp.o:
		$(CC) $(CFLAGS) $< -o $@

clean: 
	rm $(EXECUTABLE) *.o ./word_freqs
